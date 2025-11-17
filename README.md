# InkCraft A Modern Flutter Notes App

> ** A powerful and beautifully designed notes application built with Flutter, offering rich text editing, vibrant color formatting, and multi-format exporting including fully styled PDF generation.

---


# ScreenShot

![alt text](<WhatsApp Image 2025-11-17 at 21.53.42_2375325a.jpg>)

![alt text](<WhatsApp Image 2025-11-17 at 21.54.40_1b9ddada.jpg>)

![alt text](<WhatsApp Image 2025-11-17 at 21.55.58_e3592fda.jpg>)




# 🚀 Feature Highlights

### 🎨 Advanced Rich Text Editor

- Bold, Italic, Underline & Strikethrough
- Headings (H1 / H2 / H3) for structured notes
- Highlight background colors
- Real-time formatting preview
- Smooth toolbar controls

---

### 📤 Export, Print & Share

- Color-accurate PDF export
- Save notes as TXT, Markdown, or HTML
- Direct printing & print preview
- Native sharing (WhatsApp, Email, etc.)
- Copy to Clipboard for quick actions

---

### 🔧 Core Note Features

- Create, edit, pin, organize & color-code notes
- Fast search by title or body
- Auto-Save with safe recovery
- Tags (Coming soon)
- Word/Character count
- Reading time estimate

---

# 🛠️ Getting Started

> **This project requires:

```
Flutter SDK 3.0+
Dart 3.0+
VS Code (recommended)
```
---

## 💻 Flutter Setup (VS Code)

### ✔️ Step 1: Install Flutter SDK

```
Download Flutter from the official site:
https://docs.flutter.dev/get-started/install
```

> **Extract it, then add Flutter to your PATH:

```
export PATH="$PATH:/path-to-flutter/bin"
```

---

> **Check installation:

```
flutter doctor
```

---

### ✔️ Step 2: Install VS Code Extensions

> **In VS Code, install:

- Flutter
- Dart
- Error Lens (optional)
- Material Icon Theme (optional)

---

### ✔️ Step 2: Project Setup

> **Clone the repository:

```
git clone <your-repository-url>
cd InkCraft
```

> **Install dependencies:

```
flutter pub get
```

> **Run the project:

```
flutter run
```

---

# 📚 Project Structure


```

├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── note.dart
│   │   └── text_format.dart
│   ├── screens/
│   │   ├── editor_screen.dart
│   │   ├── enhanced_editor_screen.dart
│   │   ├── home_screen.dart
│   │   └── settings_screen.dart
│   ├── services/
│   │   ├── export_service.dart
│   │   ├── note_service.dart
│   │   ├── pdf_generator_service.dart
│   │   ├── preferences_service.dart
│   │   └── share_service.dart
│   ├── themes/
│   │   └── app_themes.dart
│   ├── utils/
│   │   ├── data_formatter.dart
│   │   └── rich_text_controller.dart
│   └── widgets/
│       ├── color_picker_dialog.dart
│       ├── empty_state.dart
│       ├── export_options_sheet.dart
│       ├── formatting_toolbar.dart
│       ├── note_card.dart
│       ├── note_card_new.dart
│       └── search_bar.dart
├── test/
│   └── widget_test.dart
└── windows/

```
---