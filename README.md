# TreeTask V2 ??

A modern, high-performance hierarchical task management app featuring **infinite nested subtasks** and **weighted completion tracking (scale 1?10)**.

---

## ?? Instant Browser Preview (Zero Setup)

You can test the app immediately right on your computer without installing anything:
1. Open your file explorer and go to:
   `C:\Users\Parijat-PC\Documents\Antigravity\TreeTask V2.02`
2. **Double-click `preview.html`**.
3. It will open in your web browser (Chrome, Edge, etc.) with the exact same UI, 1?10 weight slider, tree animations, progress calculations, and drill-down breadcrumbs!

---

## ?? How to Get the Android APK (Option A - Cloud Build)

You do **not** need to install Flutter or Android Studio on your computer! GitHub compiles the `.apk` file for free in the cloud.

### Step 1: Create a Repository on GitHub
1. Go to [github.com](https://github.com/) and sign in (or sign up).
2. Click the **`+`** icon in the top right corner and select **"New repository"**.
3. Name your repository `TreeTask-V2` (or any name you like).
4. Select **Public** or **Private**, and click **"Create repository"**.

### Step 2: Upload This Folder to GitHub
* On your new repository page, click **"uploading an existing file"**.
* Drag and drop the contents of the `TreeTask V2.02` folder (especially the `.github`, `android`, `lib`, and `pubspec.yaml` files) into GitHub.
* Click **"Commit changes"**.

*(Or if you use GitHub Desktop, simply select this folder and click "Publish Repository".)*

### Step 3: Download Your APK
1. In your GitHub repository, click the **"Actions"** tab at the top.
2. You will see **"Build TreeTask V2 APK"** running automatically!
3. Wait ~2?3 minutes until it turns green with a checkmark.
4. Click on the completed run, scroll down to **"Artifacts"**, and click **`TreeTask-V2-Release-APK`** to download your ready-to-install Android APK!
5. Transfer it to your phone (or download it directly on your phone's browser) and tap to install.

---

## ?? How the Weighted Mathematics Work

* **Leaf Tasks** (Tasks without children):
  * `0%` when active, `100%` when completed.
* **Parent Tasks** (Tasks with subtasks):
  $$\text{Parent Progress} = \frac{\sum_{i=1}^{n} (\text{Weight}_i \times \text{Progress}_i)}{\sum_{i=1}^{n} \text{Weight}_i}$$
* **Infinite Depth**: Every nested level calculates its weighted percentage and propagates up the branch to the top-level project.
* **Effort Tiers**:
  * ?? **1?3 (Minor)**: Quick wins, small chores.
  * ?? **4?7 (Moderate)**: Standard feature tasks, regular effort.
  * ?? **8?10 (Critical / Heavy)**: High-impact milestones, complex architectures.
