import os
import sys
import base64
import re
import shutil

def configure():
    print("[Signing] Starting release signing configuration...")

    keystore_base64 = os.environ.get("KEYSTORE_BASE64", "").strip()
    keystore_pass = os.environ.get("KEYSTORE_PASSWORD", "").strip() or "NestedStrategy2026"
    key_alias = os.environ.get("KEY_ALIAS", "").strip() or "upload"
    key_pass = os.environ.get("KEY_PASSWORD", "").strip() or "NestedStrategy2026"

    os.makedirs("android/app", exist_ok=True)
    target_keystore = "android/app/upload-keystore.jks"

    # Step 1: Ensure keystore exists
    if keystore_base64:
        print("[Signing] Decoding KEYSTORE_BASE64 from environment...")
        try:
            keystore_bytes = base64.b64decode(keystore_base64)
            with open(target_keystore, "wb") as f:
                f.write(keystore_bytes)
            print(f"[Signing] Wrote {target_keystore} from KEYSTORE_BASE64 ({len(keystore_bytes)} bytes).")
        except Exception as e:
            print(f"[Signing] ERROR decoding KEYSTORE_BASE64: {e}")
            sys.exit(1)
    elif os.path.exists("upload-keystore.jks"):
        print("[Signing] Copying root upload-keystore.jks to android/app/...")
        shutil.copy2("upload-keystore.jks", target_keystore)
        print(f"[Signing] Copied {target_keystore} ({os.path.getsize(target_keystore)} bytes).")
    elif os.path.exists(target_keystore):
        print(f"[Signing] Using existing {target_keystore} ({os.path.getsize(target_keystore)} bytes).")
    else:
        print("[Signing] ERROR: No upload-keystore.jks found! Cannot sign release.")
        sys.exit(1)

    # Step 2: Write key.properties
    key_props = (
        f"storePassword={keystore_pass}\n"
        f"keyPassword={key_pass}\n"
        f"keyAlias={key_alias}\n"
        f"storeFile=upload-keystore.jks\n"
    )
    with open("android/key.properties", "w", encoding="utf-8") as f:
        f.write(key_props)
    with open("android/app/key.properties", "w", encoding="utf-8") as f:
        f.write(key_props)
    print("[Signing] Created android/key.properties successfully.")

    # Step 3: Ensure MainActivity.kt exists
    kt_path = "android/app/src/main/kotlin/com/studioxanywhere/nested/MainActivity.kt"
    if not os.path.exists(kt_path):
        os.makedirs(os.path.dirname(kt_path), exist_ok=True)
        with open(kt_path, "w", encoding="utf-8") as f:
            f.write("package com.studioxanywhere.nested\n\nimport io.flutter.embedding.android.FlutterActivity\n\nclass MainActivity: FlutterActivity() {\n}\n")
        print("[Signing] Ensured MainActivity.kt exists.")

    # Step 4: Patch android/app/build.gradle (Groovy DSL)
    build_gradle = "android/app/build.gradle"
    if os.path.exists(build_gradle):
        with open(build_gradle, "r", encoding="utf-8") as f:
            c = f.read()

        signing_configs_code = f"""
    signingConfigs {{
        release {{
            keyAlias '{key_alias}'
            keyPassword '{key_pass}'
            storeFile file('upload-keystore.jks')
            storePassword '{keystore_pass}'
        }}
    }}
"""
        # Inject signingConfigs if not present
        if "signingConfigs {" in c:
            if "release {" not in c:
                c = c.replace("signingConfigs {", f"signingConfigs {{\n        release {{\n            keyAlias '{key_alias}'\n            keyPassword '{key_pass}'\n            storeFile file('upload-keystore.jks')\n            storePassword '{keystore_pass}'\n        }}\n")
        else:
            c = c.replace("buildTypes {", signing_configs_code + "\n    buildTypes {")

        # Replace signingConfig in release buildType
        c = re.sub(
            r"signingConfig\s*=?\s*signingConfigs\.\w+",
            "signingConfig signingConfigs.release",
            c
        )

        # Enforce exact package name, API 36, and version
        c = re.sub(r'applicationId\s+["\'][^"\']+["\']', 'applicationId "com.studioxanywhere.nested"', c)
        c = re.sub(r'namespace\s+["\'][^"\']+["\']', 'namespace "com.studioxanywhere.nested"', c)
        
        # Match any compileSdkVersion / compileSdk format (with or without = or flutter. prefix)
        c = re.sub(r'compileSdkVersion\s+.*', 'compileSdkVersion 36', c)
        c = re.sub(r'compileSdk\s*=.*', 'compileSdk = 36', c)
        c = re.sub(r'targetSdkVersion\s+.*', 'targetSdkVersion 36', c)
        c = re.sub(r'targetSdk\s*=.*', 'targetSdk = 36', c)
        c = re.sub(r'versionCode\s+.*', 'versionCode 7', c)
        c = re.sub(r'versionName\s+.*', 'versionName "2.1.4"', c)

        # Inject ndk debug symbols into release buildType if not already present
        if "debugSymbolLevel" not in c:
            c = c.replace(
                "signingConfig signingConfigs.release",
                "signingConfig signingConfigs.release\n            ndk {\n                debugSymbolLevel 'FULL'\n            }"
            )

        with open(build_gradle, "w", encoding="utf-8") as f:
            f.write(c)
        print("[Signing] Successfully patched android/app/build.gradle with API 36, symbols, release signing and com.studioxanywhere.nested package!")

    # Step 5: Patch android/app/build.gradle.kts (Kotlin DSL if present)
    build_gradle_kts = "android/app/build.gradle.kts"
    if os.path.exists(build_gradle_kts):
        with open(build_gradle_kts, "r", encoding="utf-8") as f:
            c_kts = f.read()

        signing_kts = f"""
    signingConfigs {{
        create("release") {{
            keyAlias = "{key_alias}"
            keyPassword = "{key_pass}"
            storeFile = file("upload-keystore.jks")
            storePassword = "{keystore_pass}"
        }}
    }}
"""
        if "create(\"release\")" not in c_kts:
            c_kts = c_kts.replace("buildTypes {", signing_kts + "\n    buildTypes {")
        c_kts = re.sub(
            r"signingConfig\s*=\s*signingConfigs\.getByName\(\"debug\"\)",
            "signingConfig = signingConfigs.getByName(\"release\")",
            c_kts
        )
        c_kts = re.sub(r'compileSdk\s*=.*', 'compileSdk = 36', c_kts)
        c_kts = re.sub(r'targetSdk\s*=.*', 'targetSdk = 36', c_kts)
        c_kts = re.sub(r'applicationId\s*=\s*["\'][^"\']+["\']', 'applicationId = "com.studioxanywhere.nested"', c_kts)
        c_kts = re.sub(r'namespace\s*=\s*["\'][^"\']+["\']', 'namespace = "com.studioxanywhere.nested"', c_kts)
        c_kts = re.sub(r'versionCode\s*=.*', 'versionCode = 7', c_kts)
        c_kts = re.sub(r'versionName\s*=.*', 'versionName = "2.1.4"', c_kts)

        if "debugSymbolLevel" not in c_kts:
            c_kts = c_kts.replace(
                "signingConfig = signingConfigs.getByName(\"release\")",
                "signingConfig = signingConfigs.getByName(\"release\")\n            ndk {\n                debugSymbolLevel = \"FULL\"\n            }"
            )

        with open(build_gradle_kts, "w", encoding="utf-8") as f:
            f.write(c_kts)
        print("[Signing] Successfully patched android/app/build.gradle.kts with API 36, symbols, and official release signing!")

    # Step 6: Ensure AndroidManifest.xml package matches
    manifest_path = "android/app/src/main/AndroidManifest.xml"
    if os.path.exists(manifest_path):
        with open(manifest_path, "r", encoding="utf-8") as f:
            m = f.read()
        m = re.sub(r'package\s*=\s*["\'][^"\']+["\']', 'package="com.studioxanywhere.nested"', m)
        with open(manifest_path, "w", encoding="utf-8") as f:
            f.write(m)
        print("[Signing] Ensured package='com.studioxanywhere.nested' in AndroidManifest.xml.")

    print("[Signing] Release signing configuration complete. Ready to build!")

if __name__ == "__main__":
    configure()