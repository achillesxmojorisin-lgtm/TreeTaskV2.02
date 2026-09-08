import os
import base64

def configure():
    keystore_base64 = os.environ.get("KEYSTORE_BASE64", "").strip()
    keystore_pass = os.environ.get("KEYSTORE_PASSWORD", "").strip()
    key_alias = os.environ.get("KEY_ALIAS", "").strip()
    key_pass = os.environ.get("KEY_PASSWORD", "").strip()

    if keystore_base64 and keystore_pass and key_alias and key_pass:
        print("[Signing] Release signing secrets detected. Setting up keystore...")
        os.makedirs("android/app", exist_ok=True)
        
        # 1. Decode keystore
        try:
            keystore_bytes = base64.b64decode(keystore_base64)
            with open("android/app/upload-keystore.jks", "wb") as f:
                f.write(keystore_bytes)
            print("[Signing] Wrote android/app/upload-keystore.jks successfully.")
        except Exception as e:
            print(f"[Signing] ERROR decoding KEYSTORE_BASE64: {e}")
            return

        # 2. Write key.properties
        key_props = (
            f"storePassword={keystore_pass}\n"
            f"keyPassword={key_pass}\n"
            f"keyAlias={key_alias}\n"
            f"storeFile=upload-keystore.jks\n"
        )
        with open("android/key.properties", "w", encoding="utf-8") as f:
            f.write(key_props)
        print("[Signing] Wrote android/key.properties successfully.")

        # 3. Patch android/app/build.gradle
        build_gradle_path = "android/app/build.gradle"
        if os.path.exists(build_gradle_path):
            with open(build_gradle_path, "r", encoding="utf-8") as f:
                c = f.read()

            signing_block = """
    def keystoreProperties = new Properties()
    def keystorePropertiesFile = rootProject.file('key.properties')
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        release {
            if (keystorePropertiesFile.exists()) {
                keyAlias keystoreProperties['keyAlias']
                keyPassword keystoreProperties['keyPassword']
                storeFile file(keystoreProperties['storeFile'])
                storePassword keystoreProperties['storePassword']
            }
        }
    }
"""
            if "signingConfigs {" not in c:
                c = c.replace("buildTypes {", signing_block + "\n    buildTypes {")
                c = c.replace(
                    "signingConfig signingConfigs.debug",
                    "if (keystorePropertiesFile.exists()) { signingConfig signingConfigs.release } else { signingConfig signingConfigs.debug }"
                )
                with open(build_gradle_path, "w", encoding="utf-8") as f:
                    f.write(c)
                print("[Signing] Injected signingConfigs into android/app/build.gradle.")
            else:
                print("[Signing] signingConfigs already present in build.gradle.")
        else:
            print(f"[Signing] WARNING: {build_gradle_path} not found.")
    else:
        print("[Signing] Release signing secrets not fully provided; building with default signing.")

if __name__ == "__main__":
    configure()
