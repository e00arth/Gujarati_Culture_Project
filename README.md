# ગુજરાત ની અસ્મિતા (Gujarat Ni Asmita) — Gujarati Culture Heritage Hub

A modern, high-performance, cross-platform mobile application for **Android & iOS (iPhone)** built with **Flutter 3**. The app unites Gujarati heritage, wisdom, literature, pilgrimage, and lifestyle into an interactive digital experience.

---

## 🌟 Architecture & Highlights

- **Cross-Platform**: Built natively with Flutter (`app/`) for unified deployment to Google Play Store and Apple App Store (iOS Runner workspace included).
- **Trilingual Localization**: Dynamic runtime switching between **Gujarati (ગુજરાતી)**, **Hindi (हिन्दी)**, and **English**, covering all screens, dialogs, and proverbs.
- **Modular In-App Purchase (IAP) Model**:
  - **કહેવતો (Proverbs & Wisdom)**: 100% Free Base Tier.
  - **લોકસાહિત્ય (Folklore Audio & Halarda)**: `$2.99 / ₹199` (`module_folklore_audio`) with free preview tracks.
  - **તીર્થ દર્શન (Spiritual Map & Pilgrimage)**: `$2.99 / ₹199` (`module_spiritual_map`) with free preview tours.
  - **અસ્મિતા ગ્રંથાલય (Digital Library & E-Reader)**: `$3.99 / ₹299` (`module_digital_library`) with free preview chapters and custom font scaling.
  - **જીવનશૈલી (Culture & Lifestyle)**: `$2.99 / ₹199` (`module_culture_lifestyle`) covering Ayurvedic nutrition, Patola textiles, and architecture.
  - **All-Access Heritage Pass**: `$7.99 / ₹599` (`bundle_all_access`) unlocking everything permanently.
  - **Built-in Developer IAP Sandbox**: Test purchase toggles directly inside the Lifestyle tab.

---

## 📚 1. કહેવતો (Proverbs & Wisdom Engine)

Ported with full parity from the production `kehvto` Flutter app:
- **Comprehensive Database**: Over 1,500 curated Gujarati proverbs (`kehvto.json`) with categorization across 20 themes (સંબંધો, વ્યવહાર, મહેનત, etc.).
- **5-Level Cultural Explanations**:
  1. *Backstory (પૃષ્ઠભૂમિ)*: Historical origin.
  2. *Simple Meaning (સરળ અર્થ)*: One-line concise summary.
  3. *In-Depth Meaning (સામાન્ય & ઊંડાણ)*: Nuanced philosophical context.
  4. *Folk Story (લોકકથા & દૃષ્ટાંત)*: Narrative tale illustrating the proverb.
  5. *Literal & Romanized*: Word-by-word meaning and English pronunciation guide.
- **Leitner Spaced Repetition Flashcards**: Box 1 to Box 5 daily study flow with card flipping and master status.
- **Dynamic Cultural Quiz**: 10-question randomized multiple-choice trivia testing proverb completion and meaning matching.
- **Daily Proverb**: Daily notification scheduler with time picker and modal celebration dialog.
- **Search & Favorites**: Instant indexing across Gujarati text, English meanings, and romanization with bookmarking.

---

## 🎵 2. લોકસાહિત્ય (Folklore Audio & Halarda)
- Traditional lullabies (*દીકરો મારો લાડકવાયો*, *હાલો ભાઈલાને હિંચોળે*, *શિવાજીનું હાલરડું*), Dayro ballads, and Santvani.
- Integrated audio player interface with real-time playback control, lyric scrolling, and free preview sample.

---

## 🗺️ 3. તીર્થ દર્શન (Spiritual Map & Audio Tour)
- Curated heritage guides for Somnath, Dwarka, Palitana, Ambaji, Girnar, Modhera Sun Temple, and Rani ki Vav.
- Pilgrimage audio tours, historical timelines, and key architectural highlights.

---

## 📖 4. અસ્મિતા ગ્રંથાલય (Digital Library & E-Reader)
- E-Reader for classic Gujarati literature (Kanhadade Prabandha, Saraswatichandra, Bhadrambhadra, Saurashtra Ni Rasdhar).
- Reading customizer with dynamic font sizing (`A-` / `A+`), chapters navigation, and reading progress.

---

## 🌿 5. જીવનશૈલી (Ayurveda, Architecture & Lifestyle)
- Traditional Gujarati cuisine & seasonal Ayurvedic dietetics.
- Patan Patola & Bandhani weaving heritage.
- Stepwells (*Vav*) of Gujarat and water conservation engineering.
- Interactive IAP Developer Console for testing purchase flows.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24+ (or Flutter 3.47+)
- Dart 3.13+
- Android SDK 34+ / JDK 21
- Xcode 15+ (for iOS builds on macOS)

### Running the App
```bash
cd app
flutter pub get
flutter run
```

### Running Tests
```bash
cd app
flutter test
```

### Building for Production
- **Android APK / App Bundle**:
  ```bash
  flutter build apk --release
  flutter build appbundle --release
  ```
- **iOS IPA (on macOS)**:
  ```bash
  flutter build ipa --release
  ```
