# Rebuilding TreeTask V2: Infinite Nested Tasks with Weighted Progress (Scale 1–10)

## Overview & Background
Analysis of the provided `app-debug.apk` revealed that the original app was **TreeTask** (`com.ghsoft.treetask`), built with an earlier iteration of Android Jetpack Compose. Its core model (`TaskItem`) used a recursive tree structure with:
* `id`, `name`, `description`
* `weight` (1–10)
* `isDone` (completion status)
* `createdAt`, `deadline`
* `children: List<TaskItem>`
* Weighted completion calculation: $\text{Parent Progress} = \frac{\sum (\text{weight}_i \times \text{progress}_i)}{\sum \text{weight}_i}$

The user requested a **major functionality update and a sleek modernized UI, rebuilt from scratch** using **Flutter**, built into a ready-to-install Android APK using **Option A (automated cloud build via GitHub Actions)** without needing local developer tools on their PC.

---

## Proposed Upgrades & Modernization

### 1. Visual Design & UI System
* **Material 3 / Obsidian Dark & Clean Light Theme**: Deep slate/charcoal backgrounds with vibrant modern accents (indigo/violet, emerald, amber, rose).
* **Visual Weight Hierarchy (Scale 1–10)**:
  * Tier 1 (1–3): Soft Mint / Emerald (Light effort)
  * Tier 2 (4–7): Warm Amber / Sun Gold (Medium effort)
  * Tier 3 (8–10): Coral / Crimson (High effort / High priority)
  * Shows both the weight value (`W: 7`) and its percentage contribution (`e.g., 35% of parent`).
* **Micro-interactions & Tree Rendering**:
  * Smooth accordion expand/collapse animations.
  * Subtle vertical tree-connector lines visualizing hierarchy depth.
  * Animated circular progress rings on parent nodes and linear segmented bars on detail views.

### 2. Major Functionality Additions
* **Drill-Down / Focus Mode with Breadcrumb Navigation**:
  * Tap on any subtask to drill into it as a dedicated workspace (`Home > Project Alpha > Backend > Database`).
* **Cascading Logic & Auto-Completion**:
  * When subtasks reach 100% weighted completion, the parent dynamically updates.
  * Quick option to complete all children or propagate status.
* **Filter & Search**:
  * Filter by weight range (e.g., show only Heavy tasks 8–10), completion status, or due date.
  * Real-time search across all nesting depths.
* **Offline-First Persistence & Backup**:
  * Fast local storage using JSON/SharedPreferences so it works 100% offline.
  * Export / Import tasks as JSON file for backup and transfer.
* **Automated Cloud APK Build (`.github/workflows/build-apk.yml`)**:
  * Cloud pipeline that compiles the Flutter app on GitHub's free runners and generates a downloadable `app-release.apk` with zero local build tools.

---

## File Structure (`TreeTask V2.02/`)

```
TreeTask V2.02/
├── .github/
│   └── workflows/
│       └── build-apk.yml         # Automated GitHub Actions APK compiler
├── android/                      # Standard Android build configuration
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/main/AndroidManifest.xml
│   └── build.gradle
├── lib/
│   ├── models/
│   │   └── task_item.dart        # Recursive tree model & weighted math engine
│   ├── services/
│   │   └── storage_service.dart  # Offline JSON storage & backup/export
│   ├── providers/
│   │   └── task_provider.dart    # App state, undo, filter, search, focus stack
│   ├── theme/
│   │   └── app_theme.dart        # Sleek dark/light Material 3 theme
│   ├── widgets/
│   │   ├── tree_task_item.dart   # Interactive expandable tree item
│   │   ├── weight_badge.dart     # 1-10 color gradient badge
│   │   ├── weighted_progress_bar.dart # Live progress visualization
│   │   ├── edit_task_dialog.dart # 1-10 weight slider & details modal
│   │   └── focus_breadcrumb.dart # Breadcrumb navigation header
│   ├── screens/
│   │   └── home_screen.dart      # Main dashboard & tree view
│   └── main.dart                 # App entry point
├── preview.html                  # Standalone interactive preview (browser-ready)
├── README.md                     # Step-by-step guide for building APK on GitHub
└── pubspec.yaml                  # Flutter dependencies & metadata
```

---

## Verification Plan
1. Validate Dart data models, recursive formulas, and JSON serialization.
2. Validate complete Android project structure and Gradle settings for cloud building.
3. Validate GitHub Actions workflow YAML syntax to ensure error-free cloud compilation.
4. Verify standalone interactive browser preview so the user can test the app immediately.
