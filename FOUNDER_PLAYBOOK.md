# Nested: Task Strategy — Founder's Migration & Operational Dossier 🚀

This document preserves the complete technical architecture, mathematical specifications, CI/CD pipeline, and step-by-step migration procedures for transferring Nested: Task Strategy from the testing phase to your permanent production stack.

---

## 1. Executive Summary & Core Mechanics

* **Application**: Nested: Task Strategy (Android & Multiplatform)
* **Framework**: Flutter 3.24+ (Dart)
* **Architecture**: Reactive hierarchical tree state management with offline-first local storage
* **Key Differentiator**: **Infinite nesting with weighted contribution (Scale 1–10)**

### The Mathematical Engine
* **Leaf Tasks** (Tasks without subtasks):
  $$\text{Progress} = \begin{cases} 1.0 & \text{if completed} \\ 0.0 & \text{if active} \end{cases}$$
* **Parent Tasks** (Tasks with subtasks):
  $$\text{Progress}_{\text{parent}} = \frac{\sum_{i=1}^{n} (\text{Weight}_i \times \text{Progress}_i)}{\sum_{i=1}^{n} \text{Weight}_i}$$
* **Relative Contribution**:
  $$\text{Contribution Percentage} = \left( \frac{\text{Weight}_i}{\sum \text{Weight}_{\text{siblings}}} \right) \times 100\%$$

---

## 2. Step-by-Step Migration to Your Permanent Stack

### Step 1: Set Up Your Permanent GitHub Account
1. Log in to your **real/permanent GitHub account** (e.g., your personal brand or studio name: `github.com/your-brand`).
2. Click **"+"** ➔ **"New repository"**.
3. Settings:
   * **Repository name**: `treetask-v2` (or `treetask`)
   * **Visibility**: Public (recommended for open-source credibility) or Private
   * Do NOT check "Add a README" or ".gitignore" (we already have them ready).
4. Click **Create repository**.

### Step 2: Upload the Complete Codebase
You have the complete, ready-to-use archive:
* File: `C:\Users\Parijat-PC\Documents\Antigravity\TreeTask_V2_Complete_Project.zip`
* Or folder: `C:\Users\Parijat-PC\Documents\Antigravity\TreeTask V2.02`

**Option A (Via Browser — Easiest, Zero Tools)**:
1. On your new repository page, click **"uploading an existing file"**.
2. Drag all files from `TreeTask V2.02` (including `pubspec.yaml`, `lib/`, `preview.html`, and `README.md`).
3. Click **Commit changes**.

**Option B (Creating the GitHub Action)**:
1. In your new repo, click **Actions** ➔ **"set up a workflow yourself ->"**.
2. Paste the official automated build script (see Section 3 below).
3. Click **Commit changes**.

### Step 3: Enable the Free Live Web App (GitHub Pages)
1. Go to **Settings** ➔ **Pages** in your new repository.
2. Under **Build and deployment** ➔ **Source**, select **Deploy from a branch**.
3. Set **Branch** to `main` and folder to `/(root)`.
4. Click **Save**.
5. Your app will be live worldwide at:  
   `https://<your-username>.github.io/<repo-name>/preview.html`

---

## 3. Production CI/CD Pipelines (.github/workflows)

### Pipeline A: Dual Release (Generates BOTH Android APK and Play Store AAB)
Save this as `.github/workflows/build.yml` in your new repo:

```yaml
name: Production Build (APK & AAB)

on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

jobs:
  build:
    name: Build Android Release Artifacts
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Java JDK 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Set up Flutter SDK
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.x'
          channel: 'stable'
          cache: true

      - name: Setup Android Scaffolding
        run: |
          rm -rf android
          flutter create . --platforms=android --org=com.studioxanywhere --project-name=nested

      - name: Install Dependencies
        run: flutter pub get

      - name: Build Direct-Install APK
        run: flutter build apk --release

      - name: Build Play Store App Bundle (AAB)
        run: flutter build appbundle --release

      - name: Upload APK (For direct phone testing)
        uses: actions/upload-artifact@v4
        with:
          name: Nested-Release-APK
          path: build/app/outputs/flutter-apk/app-release.apk

      - name: Upload AAB (For Google Play Store submission)
        uses: actions/upload-artifact@v4
        with:
          name: Nested-PlayStore-AAB
          path: build/app/outputs/bundle/release/app-release.aab
```

---

## 4. Open-Source Attribution & Founder Lineage

Copy and paste this into your production `README.md` and in your app's "About" dialog:

```markdown
## 💡 Lineage & Acknowledgements
TreeTask V2 is an open-source, modern reimagining of the hierarchical task concepts originally explored by **GHSoft** in the original TreeTask app. 

We loved the core concept of combining **infinite recursive nesting with weighted contribution (1–10)**, but recognized that modern users needed a sleek Material 3 user experience, fluid tree rendering, and cross-platform flexibility. TreeTask V2 was completely rebuilt from scratch in Flutter to keep this powerful productivity paradigm alive and accessible for everyone.
```

---

## 5. Release Management Strategy (New Versions vs In-Place Updates)

The automated GitHub Actions workflow (`.github/workflows/main.yml`) supports two operating modes:

### Mode 1: Creating a New Version Release (Permanent Version History)
Whenever you introduce a major feature, new capability, or milestone:
1. Bump `version:` in `pubspec.yaml` (e.g. `2.2.0+4`).
2. Tag and push to GitHub:
   ```bash
   git tag v2.2.0
   git push origin v2.2.0
   ```
   *Alternatively*: Go to GitHub Actions ➔ click "Build Nested: Task Strategy" ➔ "Run workflow" ➔ enter `v2.2.0`.
3. GitHub Actions automatically compiles `app-release.apk` and `app-release.aab`, creates a new release entry `v2.2.0`, and lists it at the top of the Releases tab while **permanently preserving all past versions** (`v2.1.0`, `v2.0.0`, etc.).

### Mode 2: In-Place Update (Same Release, No Version Bump)
Whenever you push minor fixes, tweaks, or updates that do *not* require a new version number:
1. Simply commit and push your changes to `main`:
   ```bash
   git commit -m "fix: minor UI alignment adjustment"
   git push origin main
   ```
2. GitHub Actions detects that no new tag was created, automatically finds the current active release (e.g. `v2.1.0`), and **replaces the binaries (`app-release.apk` and `app-release.aab`) in-place** inside that existing release using `--clobber`.
3. No duplicate release entry is generated; users downloading from the latest release always get your most up-to-date binaries.

---

## 6. Official Google Play App Signing & Keystore Specifications 🔑

A permanent 10,000-day RSA 2048-bit **Upload Keystore** has been generated for **Nested: Task Strategy**.

### Keystore Metadata
* **File Name**: `upload-keystore.jks`
* **Local Master Backup**: `C:\Users\choud\Documents\Antigravity Workspace\Project 1\upload-keystore.jks`
* **Alias**: `upload`
* **Keystore Password**: `NestedStrategy2026`
* **Key Password**: `NestedStrategy2026`
* **Validity**: 10,000 days (valid through January 24, 2054)

### Cryptographic Certificate Fingerprints
* **SHA-1**: `AB:B6:CC:95:CD:71:97:B7:AB:DD:15:31:9D:C4:94:86:69:67:6D:1F`
* **SHA-256**: `8A:CD:A9:41:26:FB:1D:2D:0B:F5:92:9F:22:66:10:91:1F:5A:93:BB:E0:32:BA:02:E6:91:71:74:61:F3:5D:FE`

### Configuring Automated Signing in GitHub Actions
To have GitHub Actions sign every production APK and AAB with this official key automatically:
1. Go to your GitHub Repository:
   `https://github.com/studioxanywhere-hub/Nested-TaskStrategy/settings/secrets/actions`
2. Click **"New repository secret"** and add the following 4 secrets:

| Secret Name | Value | Description |
| :--- | :--- | :--- |
| `KEYSTORE_PASSWORD` | `NestedStrategy2026` | Master password for the keystore |
| `KEY_PASSWORD` | `NestedStrategy2026` | Password for the key alias |
| `KEY_ALIAS` | `upload` | Alias name of the key entry |
| `KEYSTORE_BASE64` | *(Base64 string from scratch/keystore_base64_utf8.txt)* | Complete binary keystore encoded in Base64 |

> [!IMPORTANT]
> Keep `upload-keystore.jks` stored in a safe backup location (e.g. Google Drive, USB, or password manager). This is the master upload key for the life of the app on Google Play.

---

## 7. Cleaning Up Your Trial Accounts

Once you have verified that your permanent GitHub repository has the code and the Actions run produces your artifacts:
1. Go to your temporary GitHub account (`achillesxmojorisin-lgtm`).
2. In the temporary `TreeTaskV2.02` repo, go to **Settings** ➔ scroll to the bottom (**Danger Zone**) ➔ click **Delete this repository**.
3. Or simply mark it as Private.
