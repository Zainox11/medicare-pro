# 🏥 MediCare Pro — Hospital Appointment Booking App

A full-featured Flutter + Firebase hospital management app with role-based access control,
appointment scheduling, prescription management, and more.

---

## 📱 Features

| Feature | Description |
|---|---|
| 🔐 Secure Auth | Firebase Auth — login, register, reset password |
| 👥 Role-Based Access | Patient / Doctor / Admin roles with separate dashboards |
| 🩺 Doctor Listings | Browse all verified doctors with filters |
| 🔍 Specialization Filter | Filter by 15+ specializations + search by name |
| 📅 Appointment Booking | Calendar date picker + time slot booking |
| 💻 Online Consultation | Video consultation booking flow |
| 💊 Prescription Management | Doctors write digital prescriptions per appointment |
| 📋 Patient Records | Doctors view patient history |
| 🔔 Push Notifications | FCM push + local notification reminders |
| 👤 Profile Management | Editable profiles for patients and doctors |
| 🛡️ Admin Dashboard | Verify doctors, view stats, manage users |
| ☁️ Cloud Database | Firestore with proper security rules |
| 📐 Clean Architecture | Data → Repository → Provider → Presentation |

---

## 🗂️ Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/app_constants.dart
│   ├── theme/app_theme.dart
│   └── router/app_router.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── doctor_model.dart
│   │   ├── appointment_model.dart
│   │   └── prescription_model.dart
│   └── services/
│       ├── auth_service.dart
│       ├── firestore_service.dart
│       └── notification_service.dart
├── providers/
│   └── auth_provider.dart
└── presentation/
    ├── auth/screens/
    │   ├── splash_screen.dart
    │   ├── onboarding_screen.dart
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── patient/
    │   ├── screens/
    │   │   ├── patient_home_screen.dart
    │   │   ├── doctor_list_screen.dart
    │   │   ├── doctor_detail_screen.dart
    │   │   ├── book_appointment_screen.dart
    │   │   ├── my_appointments_screen.dart
    │   │   ├── prescription_screen.dart
    │   │   ├── patient_profile_screen.dart
    │   │   ├── notifications_screen.dart
    │   │   └── online_consultation_screen.dart
    │   └── widgets/
    │       ├── custom_text_field.dart
    │       └── doctor_card.dart
    ├── doctor/screens/
    │   ├── doctor_home_screen.dart
    │   ├── doctor_appointments_screen.dart
    │   ├── doctor_profile_screen.dart
    │   ├── write_prescription_screen.dart
    │   └── patient_records_screen.dart
    └── admin/screens/
        ├── admin_dashboard_screen.dart
        └── manage_doctors_screen.dart
```

---

## 🚀 How to Run — Step by Step

### ✅ PREREQUISITES

Make sure you have:

- **Flutter SDK** ≥ 3.0.0 → https://docs.flutter.dev/get-started/install
- **Android Studio** or **VS Code** with Flutter extension
- **Firebase CLI** → `npm install -g firebase-tools`
- **FlutterFire CLI** → `dart pub global activate flutterfire_cli`
- **Git** (optional)
- A **Firebase account** (free) → https://console.firebase.google.com

---

### STEP 1 — Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **"Add project"** → name it `medicare-pro` (or anything)
3. Disable Google Analytics (optional) → **Create project**

---

### STEP 2 — Enable Firebase Services

In your Firebase project, enable:

**Authentication:**
- Left sidebar → **Authentication** → Get Started
- Sign-in method → Enable **Email/Password** → Save

**Firestore Database:**
- Left sidebar → **Firestore Database** → Create database
- Choose **Start in test mode** (you'll add proper rules later)
- Select your region (e.g., `asia-south1` for Pakistan) → Done

**Firebase Storage (optional for profile images):**
- Left sidebar → **Storage** → Get Started → Next → Done

**Firebase Cloud Messaging:**
- Left sidebar → **Project Settings** → Cloud Messaging tab
- Note your **Server Key** (needed for push notifications)

---

### STEP 3 — Connect Firebase to Flutter

In the project root directory, run:

```bash
# Login to Firebase
firebase login

# Connect Firebase to Flutter app
flutterfire configure
```

Follow the prompts:
- Select your Firebase project
- Select platforms: **Android** and **iOS**
- This auto-generates `lib/firebase_options.dart` ✅
- This auto-downloads `google-services.json` → `android/app/` ✅
- This auto-downloads `GoogleService-Info.plist` → `ios/Runner/` ✅

---

### STEP 4 — Install Dependencies

```bash
flutter pub get
```

---

### STEP 5 — Add Firestore Security Rules

1. Go to Firebase Console → **Firestore Database** → **Rules**
2. Copy the entire contents of `firestore.rules` (in project root)
3. Paste into the Rules editor → **Publish**

---

### STEP 6 — Add Firestore Indexes

1. Go to Firebase Console → **Firestore Database** → **Indexes**
2. The indexes will be auto-created when queries run, OR you can run:

```bash
firebase deploy --only firestore:indexes
```

---

### STEP 7 — Run the App

**For Android (emulator or physical device):**

```bash
# Check connected devices
flutter devices

# Run on Android
flutter run
```

**For iOS (Mac only):**

```bash
cd ios && pod install && cd ..
flutter run
```

**For specific device:**

```bash
flutter run -d <device_id>
```

---

### STEP 8 — Seed Test Data (Optional)

To add sample doctors, go to Firebase Console → **Firestore** → manually add a document in the `doctors` collection:

```json
{
  "name": "Ahmed Khan",
  "email": "dr.ahmed@hospital.com",
  "phone": "03001234567",
  "specialization": "Cardiologist",
  "qualification": "MBBS, FCPS (Cardiology)",
  "hospital": "Aga Khan Hospital, Karachi",
  "consultationFee": 2000,
  "onlineConsultationFee": 1500,
  "experience": 12,
  "about": "Experienced cardiologist with 12+ years...",
  "availableDays": ["Monday","Tuesday","Wednesday","Thursday","Friday"],
  "availableTimeSlots": ["09:00 AM","10:00 AM","11:00 AM","02:00 PM"],
  "isAvailableOnline": true,
  "isVerified": true,
  "isActive": true,
  "rating": 4.8,
  "totalReviews": 145,
  "createdAt": "<server timestamp>",
  "role": "doctor"
}
```

---

## 🔑 Test Credentials Flow

1. **Register as Patient** → goes to Patient Dashboard
2. **Register as Doctor** → goes to Doctor Dashboard (fill profile to appear in listings)
3. **Admin account** → manually set `role: "admin"` in Firestore `users` collection for an existing account

---

## 🏗️ Build for Release

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (for Play Store):**
```bash
flutter build appbundle --release
```

**iOS IPA (Mac only):**
```bash
flutter build ios --release
```

---

## 🧪 Common Issues & Fixes

| Issue | Fix |
|---|---|
| `google-services.json not found` | Run `flutterfire configure` again |
| `Gradle build failed` | Run `flutter clean && flutter pub get` |
| `Firebase Auth not initialized` | Make sure `await Firebase.initializeApp()` runs in `main()` |
| `Permission denied Firestore` | Check your Firestore Security Rules |
| `No doctors shown` | Add doctors manually OR register as Doctor and complete profile |
| `iOS pod install fails` | Run `cd ios && pod repo update && pod install` |
| `Notification not working on Android 13+` | Grant notification permission in device settings |

---

## 🧩 Tech Stack

| Layer | Technology |
|---|---|
| UI | Flutter 3.x + Material 3 |
| State | Riverpod 2.x |
| Navigation | GoRouter |
| Backend | Firebase (Auth, Firestore, Storage, FCM) |
| Local Notifications | flutter_local_notifications |
| Calendar | table_calendar |
| Fonts | Google Fonts (Poppins) |
| HTTP Images | cached_network_image |
| Architecture | Clean Architecture (Data / Provider / Presentation) |

---


