# RedDay 🌿 — Private, Offline Menstrual Cycle & Partner Care Tracker

RedDay is a complete, production-quality, offline-first menstrual cycle and partner care tracking application built with **Flutter** and **Dart** for Android (**Android 7.0 Nougat / API 24 and higher**). Designed around a high-contrast **2-Color Editorial Palette (`#1e1e1c` Charcoal Ink & `#d8cbb3` Warm Sand)** and **Noto Sans** high-readability typography, RedDay offers a calming, private, and easy-to-use experience in **English** and **Bahasa Indonesia** — for both personal cycle tracking and **Boyfriend / Partner Mode** — with zero external dependencies, zero accounts, and zero cloud tracking.

---

## 🌟 Key Highlights & Privacy Guarantees

- **100% Offline-First:** Runs purely locally on your Android device. No server, no remote APIs, no telemetry, and no analytics.
- **Zero Account Requirement:** Open the app and begin tracking immediately. No email, password, or sign-up required.
- **Strict 2-Color High-Readability Design:** Uses exclusively `#1e1e1c` and `#d8cbb3` (**10.41:1 WCAG AAA contrast ratio**) paired with **Noto Sans** humanist sans-serif typography engineered for screen legibility (`1.5`–`1.55` line height, positive letter spacing, and minimum `12sp` labels).
- **Bilingual (English & Bahasa Indonesia):** Prompts first-time users to choose their preferred language at startup and supports instant language switching in Settings.
- **First-Time User Interactive Tutorial Only:** Guides new users through a 4-step interactive walkthrough on their first launch only (`prefKeyTutorialComplete`), with a help button in the Home header to replay anytime.
- **Boyfriend / Partner Mode & Care Reminders:** Dedicated mode allowing a boyfriend or partner to track her cycle, receive **Boyfriend Care Reminders**, use a 5-day default when he does not know her exact period duration, and select **"Not Sure"** when he does not know if her period blood flow is light or heavy.
- **"Today is the First Day" Quick Start:** One-tap option right on first app start and on the Cycle Baseline screen to mark **Today is the first day (`Hari ini hari pertama`)** without opening a calendar dialog.
- **Android 7.0+ (`minSdk = 24`) & Release Compression:** Compatible with Android 7.0 Nougat (`API 24`) and higher via Java core library desugaring, and compressed for release with R8 code shrinking (`isMinifyEnabled = true`), resource shrinking (`isShrinkResources = true`), ProGuard optimization rules, and stripped font assets.
- **Device-Local Storage & Cloud Backup Exclusion:** All period history, daily logs, and symptom data stay inside a sandboxed SQLite database on-device, with `allowBackup="false"` and `data_extraction_rules.xml` blocking unencrypted cloud backups.
- **Secure Data Portability:** Export your entire dataset as a standardized JSON backup and restore it anytime using Android's Storage Access Framework (SAF).

---

## 📱 Features

### 1. First-Time Setup & Onboarding
- **Language Prompt on First Start:** Asks *"Which language would you like to use? / Bahasa apa yang ingin Anda gunakan?"* (**English** or **Bahasa Indonesia**).
- **User Mode Selection:** Choose **For Myself (`Untuk Diri Sendiri`)** or **Boyfriend Mode (`Mode Pacar`)**.
- **"Today is the First Day" Quick Option:** Immediately select **Today is the first day (`Hari ini hari pertama`)** on the welcome screen or baseline screen, or pick another date.
- **"Do You Know the Period Duration?" (`Apakah Anda tahu durasi haid?`):** Choose **Yes, I know** to customize sliders, or **Not sure** to automatically apply the clinical standard **5-day period duration** and **28-day cycle**.

### 2. Home & Cycle Dashboard
- **Organic Circular Cycle Gauge:** Displays current cycle day, active phase (Menstrual, Follicular, Ovulation, Luteal), and countdown to the next estimated period.
- **1-Tap Boyfriend Mode Switch:** Toggle **Boyfriend Mode (`Mode Pacar`)** directly from the Home header.
- **Boyfriend Care & Reminder Hub (`BoyfriendCareCard`):** Displayed when Boyfriend Mode is active; shows her current phase status, a quick toggle for **Boyfriend Care Reminder (`Pengingat Perhatian Pacar`)**, and an interactive daily care checklist.
- **First-Time Guide Card & Interactive Tutorial:** 4-step walkthrough shown only on first launch.
- **Quick Logging Actions:** One-tap period logging, daily symptom check-ins, calendar jump, and insights shortcut.

### 3. Period & Flow Logging (Partner-Friendly)
- Track start and end dates with single-day, multi-day, or ongoing period states.
- **"Do you know the period duration?" Toggle:** When turned off (or in Boyfriend Mode), automatically estimates a 5-day period from the start date so a partner never has to guess when it ends.
- **Flow Intensity with `"Not Sure"` Option:** Log flow intensity as **Not Sure (`not_sure`)**, **Spotting**, **Light**, **Medium**, or **Heavy** — ideal when a boyfriend does not know whether the period blood is a lot or not.
- Strict validation preventing overlapping period date ranges and impossible dates.

### 4. Comprehensive Symptom Tracking
- Log 14 granular menstrual health symptoms across 3 severity levels (Mild, Moderate, Severe):
  - *Physical:* Cramps, Headache, Backache, Bloating, Breast Tenderness, Fatigue, Nausea, Acne.
  - *Emotional:* Mood Swings, Irritability, Anxiety, Low Energy.
  - *Discharge:* Spotting, Watery Discharge.
- Includes `FlowIntensity.notSure` (**"Not Sure"**) and optional daily personal notes.

### 5. Interactive Menstrual Calendar
- Custom 7-column monthly calendar grid showing past periods, predicted periods, and estimated fertile windows using high-contrast `#1e1e1c` and `#d8cbb3` patterns and shape markers.
- Tap any date to inspect historical periods or launch daily symptom logs.

### 6. Smart Prediction Engine
- Pure Dart cycle calculation engine:
  - Dynamically calculates historical average cycle length and duration.
  - Automatically trims statistical outliers when 4 or more valid cycles exist.
  - Falls back smoothly to onboarding baselines (5-day duration / 28-day cycle) when fewer than 2 periods exist or when period duration is marked unknown.
  - Computes estimated fertile window and ovulation day.

### 7. Health Insights & Visual Analytics
- Visualized using `fl_chart`:
  - **Cycle Length History:** Bar chart of past cycle lengths compared against baseline.
  - **Period Duration Trend:** Line graph tracking duration variances over time.
  - **Symptom Frequency Distribution:** Horizontal frequency bars identifying the most prevalent symptoms.

### 8. Red Day Diet & Nutrition Guide (WHO & ACOG Evidence-Based)
- **Clinical & Peer-Reviewed Grounding:**
  - **WHO (World Health Organization):** Guidelines on non-heme dietary iron replenishment, calcium intake, and low-sodium (`<2g/day` sodium) balance for menstruating women.
  - **ACOG (American College of Obstetricians and Gynecologists):** Clinical practice guidelines on calcium, magnesium, and complex carbohydrate stabilization for dysmenorrhea and PMS relief.
  - **WHO & ACOG-Backed Cheese Entry (`cheese_calcium`):** Low-sodium, pasteurized calcium-rich cheeses (*Warm Whole-Grain Grilled Cheese & Tomato Soup*, *Spinach & Feta Stuffed Omelet*, *Cottage Cheese Bowl with Pineapple & Walnuts*, *Warm Baked Ricotta with Honey & Thyme*) with lactose-free / plant-based allergy swaps.
  - **Peer-Reviewed Clinical Trials:** Ginger rhizome analgesia, dark chocolate magnesium myometrial relaxation, omega-3 prostaglandin suppression, and turmeric curcumin anti-inflammatory support.
- **Intelligent Allergy Filtering:** Flags potential allergens (Dairy, Nuts, Gluten, Seafood, Eggs, Soy) or filters for 100% safe alternatives with one tap.

### 9. Boyfriend Reminders, Notifications & Settings
- **Boyfriend Care Reminder (`Pengingat Perhatian Pacar`):** Dedicated local notification reminding the boyfriend before her period starts and on active Red Days to prepare comfort snacks, warm drinks, and extra patience.
- **Period & Daily Check-in Reminders:** Configurable notification time and well-spaced **Days before (`Hari sebelumnya`)** selector (`On the day`, `1 day before`, `2 days before`, `3 days before`, `5 days before`).
- **Theme & Language Controls:** Switch between Light (`#d8cbb3` background / `#1e1e1c` ink), Dark (`#1e1e1c` background / `#d8cbb3` sand), or System theme, and toggle between **English** and **Bahasa Indonesia** anytime.

---

## 🏛️ Project Architecture

RedDay follows a clean, modular Flutter architecture with unidirectional data flow using the **Provider** state management pattern:

```text
lib/
├── app.dart                                # RedDayApp root widget and MultiProvider wiring
├── main.dart                               # Application entrypoint with local DB and notification bootstrap
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                 # Strict 2-color palette (#1e1e1c & #d8cbb3) + ThemeExtension
│   │   ├── app_constants.dart              # Cycle boundaries, notification IDs, settings & pref keys
│   │   └── app_text_styles.dart            # Noto Sans WCAG high-readability typography scale
│   ├── database/
│   │   └── app_database.dart               # SQLite database setup, migrations, and index definitions
│   ├── errors/
│   │   └── app_exception.dart              # Domain-specific exception hierarchy
│   ├── theme/
│   │   └── app_theme.dart                  # Material 3 Light/Dark 2-color theme configuration
│   └── utils/
│       └── date_utils.dart                 # Normalized date math, ISO formatting, range checks
├── models/
│   ├── app_settings.dart                   # User preferences, Boyfriend Mode, and cycle baselines
│   ├── cycle_prediction.dart               # Predicted dates, phases, and cycle statistics
│   ├── daily_log.dart                      # Daily symptom, notes, and FlowIntensity (including notSure)
│   ├── nutrition_item.dart                 # Evidence-based food, dish, and clinical citation models
│   ├── period.dart                         # Menstrual period record
│   └── symptom.dart                        # Symptom definitions and severity mapping
├── repositories/
│   ├── daily_log_repository.dart           # Daily log & symptom join table queries
│   ├── nutrition_repository.dart           # Curated WHO/ACOG/PubMed nutrition & Cheese database
│   ├── period_repository.dart              # Period CRUD with overlap validation
│   └── settings_repository.dart            # Key-value SQLite settings store
├── services/
│   ├── cycle_prediction_service.dart       # Algorithmic cycle averaging and phase prediction
│   ├── export_service.dart                 # Backup serialization, validation, and SAF file picker
│   └── notification_service.dart           # Local period, daily, and Boyfriend Care notifications
├── providers/
│   ├── calendar_provider.dart              # Calendar month navigation and selected day state
│   ├── daily_log_provider.dart             # Daily symptom logging state
│   ├── insights_provider.dart              # Filtered stats and chart aggregation state
│   ├── locale_provider.dart                # English ('en') & Bahasa Indonesia ('id') localization
│   ├── period_provider.dart                # Periods, predictions, and settings coordinator
│   └── theme_provider.dart                 # ThemeMode persistence
├── shared/
│   └── widgets/
│       ├── app_button.dart                 # Primary, secondary, and destructive buttons
│       ├── app_card.dart                   # High-contrast 2-color cards
│       ├── confirm_dialog.dart             # Reusable confirmation dialogs
│       └── leaf_badge.dart                 # Organic status indicators
└── features/
    ├── navigation/
    │   └── app_shell.dart                  # 4-tab IndexedStack + first-time tutorial launcher
    ├── onboarding/
    │   ├── onboarding_screen.dart          # 4-step setup (Language, Mode, Today Day 1, Duration, Reminders)
    │   └── first_time_tutorial_dialog.dart # 4-step interactive tutorial for first-time users
    ├── home/
    │   ├── home_screen.dart
    │   └── widgets/
    │       ├── boyfriend_care_card.dart    # Boyfriend Care & Reminder Hub + checklist
    │       ├── daily_summary_card.dart     # Today's symptom summary
    │       ├── first_time_tutorial_card.dart # First-time user guide banner
    │       ├── main_cycle_card.dart        # Circular progress ring
    │       ├── period_timeline_card.dart   # Recent cycle timeline
    │       ├── quick_actions.dart          # 2x2 accessible quick action grid
    │       └── red_day_nutrition_card.dart # Context-aware nutrition & comfort food card
    ├── calendar/
    │   ├── calendar_screen.dart
    │   └── widgets/
    │       ├── calendar_grid.dart          # 7-column custom day grid
    │       ├── calendar_legend.dart        # Pattern & shape accessibility key
    │       └── day_detail_card.dart        # Selected day inspector
    ├── period_logging/
    │   └── period_log_screen.dart          # Period entry with unknown-duration & "Not Sure" flow support
    ├── symptom_tracking/
    │   └── symptom_tracking_screen.dart    # 14-symptom grid with severity & "Not Sure" flow option
    ├── insights/
    │   ├── insights_screen.dart
    │   └── widgets/
    │       ├── cycle_trend_chart.dart      # Bar chart of cycle lengths
    │       ├── duration_chart.dart         # Period duration line graph
    │       ├── stat_summary_card.dart      # Average cycle metrics
    │       └── symptom_frequency_chart.dart# Symptom distribution bars
    ├── nutrition/
    │   ├── dietary_preferences_dialog.dart # Allergy and comfort cravings editor
    │   └── nutrition_screen.dart           # Food suggestions, WHO Cheese guide, and dish recipes
    └── settings/
        ├── privacy_screen.dart             # Detailed offline security & medical disclaimer
        └── settings_screen.dart            # Appearance, Language, Boyfriend Mode, Reminders & Backup
```

---

## 🛠️ Requirements & Tech Stack

- **Flutter SDK:** 3.24.0 or higher
- **Target Platform:** Android **7.0 Nougat (`minSdk = 24`)** through Android 15 (`targetSdk = 35`, `compileSdk = 35`)
- **Java Development Kit (JDK):** JDK 17 or higher with Core Library Desugaring (`desugar_jdk_libs:2.1.4`)
- **Release Optimization:** R8 code minification (`isMinifyEnabled = true`), resource shrinking (`isShrinkResources = true`), and custom ProGuard rules (`android/app/proguard-rules.pro`)

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
cd "c:\Personal Project\reday"
flutter pub get
```

### 2. Run Static Code Analysis
RedDay adheres to strict Flutter lint rules with zero issues:
```bash
flutter analyze
```

### 3. Run Automated Test Suite
The automated test suite covers algorithmic predictions, date boundary math, database integrity, backup import/export, WHO nutrition & Cheese filtering, 2-color theme & Noto Sans typography, bilingual onboarding, first-time tutorial, Boyfriend Mode flows, and narrow-screen responsive layout verification:
```bash
flutter test
```
*Current test suite: **39 tests passing (100% pass rate)**.*

---

## 🔨 Building & Compressing for Release

### Build Compressed Release APK (Android 7.0 / API 24+)
```bash
flutter build apk --release --split-per-abi
```
Or build a universal release APK:
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Pre-Packaged Release Archive
A clean, compressed release source archive is also maintained at the project root:
- `redday-release.zip`

---

## 🛡️ Security & Privacy Architecture

- **No Network Permissions:** `AndroidManifest.xml` does **not** declare `<uses-permission android:name="android.permission.INTERNET" />`. The operating system guarantees that no network packet can be transmitted from RedDay.
- **Excluded from Cloud Backups:** `android:allowBackup="false"` and `android:dataExtractionRules` prevent automatic cloud backup of cycle data.
- **Safe Local Reminders:** Notifications are scheduled locally on-device without remote push servers.

---

## ⚖️ Medical Disclaimer

RedDay is intended solely for personal cycle tracking, partner support, and wellness awareness. Menstrual cycle length and ovulation timing vary due to stress, illness, hormonal fluctuations, and other factors. RedDay's calculations **must not** be used as a form of contraception or for medical diagnosis. Always consult a qualified healthcare professional for medical advice.
