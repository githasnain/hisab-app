# Home Expense Manager (Hisab App)

A simple, offline-only Android app for tracking home expenses, designed for ease of use with large text and high contrast.

## Project Structure

```
hisab_app/
├── pubspec.yaml            # Dependencies
├── lib/
│   ├── main.dart           # App Entry & Theme
│   ├── boxes.dart          # Hive Box Access
│   ├── models/
│   │   └── expense.dart    # Data Model & Adapter
│   └── screens/
│       ├── home_screen.dart        # Dashboard
│       ├── add_expense_screen.dart # Add Entry Form
│       ├── history_screen.dart     # List of Expenses
│       └── summary_screen.dart     # Monthly Stats
```

## Prerequisites

1.  **Flutter SDK**: Ensure Flutter is installed.
    -   Download from [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
    -   Extract to `C:\src\flutter` (or similar)
    -   Add `flutter\bin` to your System Path.
2.  **Android Device**: A real Android phone connected via USB.

## Step-by-Step Setup

### 1. Connect Real Android Device
1.  On your phone, go to **Settings > About Phone**.
2.  Tap **Build Number** 7 times to enable **Developer Options**.
3.  Go back to **Settings > System > Developer Options**.
4.  Enable **USB Debugging**.
5.  Connect phone to PC via USB cable.
6.  Allow USB Debugging prompt on phone screen.

### 2. Verify Connection
Open a terminal (PowerShell or CMD) in this folder and run:
```powershell
flutter devices
```
You should see your device listed (e.g., `SM G990E • device-id • android-arm64`).

### 3. Install Dependencies
Run the following command to download all required packages:
```powershell
flutter pub get
```

### 4. Run the App
To run the app on your connected phone:
```powershell
flutter run
```
-   The app will install and open on your phone.
-   **Note**: The first build may take a few minutes.

### 5. Build Final APK
To create an APK file that you can share or install permanently:
```powershell
flutter build apk --release
```
-   Once finished, the APK will be located at:
    `build\app\outputs\flutter-apk\app-release.apk`
-   Copy this file to your phone and install it.

## Features
-   **Offline Storage**: Uses Hive NoSQL database. No internet required.
-   **Simple UI**: Large buttons, high contrast, easy navigation.
-   **Expense Tracking**: Add amount, category, date, and notes.
-   **History**: View and delete past expenses.
-   **Summary**: View monthly totals and category-wise breakdown.

## Future Improvements (No Backend Required)
-   **Export to PDF/CSV**: Generate reports to share via WhatsApp.
-   **Budget Limits**: Set a monthly limit and get alerts.
-   **Backup/Restore**: Save data to a local file for backup.
-   **Dark Mode Toggle**: Allow user to switch themes manually.
