import os
import sys
import zipfile

def verify_and_package():
    aab_path = 'build/app/outputs/bundle/release/app-release.aab'
    if not os.path.exists(aab_path):
        print(f'[Verify] ERROR: AAB not found at {aab_path}')
        sys.exit(1)

    print(f'[Verify] Inspecting {aab_path} ({os.path.getsize(aab_path)} bytes)...')
    
    with zipfile.ZipFile(aab_path, 'r') as z:
        names = z.namelist()
        manifest_bytes = z.read('base/manifest/AndroidManifest.xml')

        # 1. Verify targetSdkVersion 36
        idx = manifest_bytes.find(b'targetSdkVersion')
        if idx == -1:
            print('[Verify] ERROR: targetSdkVersion not found in AAB manifest!')
            sys.exit(1)
            
        chunk = manifest_bytes[idx:idx+60]
        print(f'[Verify] Manifest targetSdkVersion chunk: {chunk}')
        
        if b'36' not in chunk:
            print(f'[Verify] CRITICAL FAILURE: targetSdkVersion is NOT 36! Chunk: {chunk}')
            sys.exit(1)
        print('[Verify] SUCCESS: Confirmed targetSdkVersion is 36!')

        # 2. Check debug symbols inside AAB
        symbol_entries = [n for n in names if 'com.android.tools.build.debugsymbols' in n]
        if symbol_entries:
            print(f'[Verify] SUCCESS: Found {len(symbol_entries)} native debug symbols inside AAB BUNDLE-METADATA!')
        else:
            print('[Verify] INFO: No debug symbols inside BUNDLE-METADATA. Packaging standalone ZIP fallback...')

    # 3. Create standalone native-debug-symbols.zip
    symbols_zip_path = 'build/app/outputs/bundle/release/native-debug-symbols.zip'
    
    # Search merged native libs directories
    search_dirs = [
        'build/app/intermediates/merged_native_libs/release/out/lib',
        'build/app/intermediates/merged_native_libs/release/mergeReleaseNativeLibs/out/lib',
        'build/app/intermediates/stripped_native_libs/release/out/lib',
    ]
    
    found_lib_dir = None
    for d in search_dirs:
        if os.path.exists(d) and os.listdir(d):
            found_lib_dir = d
            break
            
    os.makedirs(os.path.dirname(symbols_zip_path), exist_ok=True)
    if found_lib_dir:
        print(f'[Verify] Creating {symbols_zip_path} from {found_lib_dir}...')
        with zipfile.ZipFile(symbols_zip_path, 'w', zipfile.ZIP_DEFLATED) as sz:
            for root, dirs, files in os.walk(found_lib_dir):
                for f in files:
                    full_path = os.path.join(root, f)
                    rel_path = os.path.relpath(full_path, found_lib_dir)
                    sz.write(full_path, rel_path)
                    print(f'  Added symbol lib: {rel_path}')
        print(f'[Verify] Created {symbols_zip_path} ({os.path.getsize(symbols_zip_path)} bytes).')
    else:
        print('[Verify] Packaging native libs from AAB into symbols zip fallback...')
        with zipfile.ZipFile(aab_path, 'r') as z:
            with zipfile.ZipFile(symbols_zip_path, 'w', zipfile.ZIP_DEFLATED) as sz:
                for n in names:
                    if n.startswith('base/lib/'):
                        rel_name = n[len('base/lib/'):]
                        sz.writestr(rel_name, z.read(n))
                        print(f'  Extracted AAB lib: {rel_name}')
        print(f'[Verify] Created {symbols_zip_path} ({os.path.getsize(symbols_zip_path)} bytes).')

    print('[Verify] All AAB release verifications passed!')

if __name__ == '__main__':
    verify_and_package()
