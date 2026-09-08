# Nested: Task Strategy 🌲🎯

A modern, high-performance hierarchical task management app featuring **infinite nested subtasks** and **weighted completion tracking (scale 1–10)**.

* **Live Web App**: [https://studioxanywhere-hub.github.io/TreeTaskV2.02/](https://studioxanywhere-hub.github.io/TreeTaskV2.02/)
* **Privacy Policy**: [https://studioxanywhere-hub.github.io/TreeTaskV2.02/privacy.html](https://studioxanywhere-hub.github.io/TreeTaskV2.02/privacy.html)

---

## 🌐 Instant Web & Browser App (Zero Setup)

You can run and test the app right in your browser (desktop, tablet, or mobile):
* Open [https://studioxanywhere-hub.github.io/TreeTaskV2.02/](https://studioxanywhere-hub.github.io/TreeTaskV2.02/)
* Works 100% offline with instant local persistence.

---

## 📱 Automated Cloud Android Builds (APK & Google Play AAB)

You do **not** need to install Flutter or Android Studio on your computer! GitHub Actions automatically compiles both the direct-install `.apk` and the Google Play Store `.aab` bundle on every push:

1. In your GitHub repository, click the **"Actions"** tab at the top.
2. Click the latest green workflow run.
3. Under **"Artifacts"**, you will find:
   * **`Nested-Release-APK`**: Direct install on any Android phone.
   * **`Nested-PlayStore-AAB`**: Upload-ready bundle for Google Play Console!

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
