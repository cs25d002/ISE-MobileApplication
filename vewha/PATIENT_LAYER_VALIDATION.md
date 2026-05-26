# VEWHA — Patient Layer Manual Validation Protocol

This file serves as the official operational guide and checklist for verifying and running the patient-facing layer of the **VEWHA** mobile health app.

---

## 1. Quick Launch Commands

To launch and run the app under different modes, execute the following commands in the `vewha/` directory:

### Clinician-Facing Mode (Original App)
Launches the original, clinician Welcome and login flows (fully retaining Firebase authentication dependencies and DB providers):
```bash
flutter run
```

### Patient-Facing Evaluation Mode (Enhanced Layer)
Launches the progressive prescription list and enrollment screen directly, completely bypassing any auth/login gates and welcome screen delays:
```bash
flutter run --dart-define=MODE=patient
```

---

## 2. Automated Test Execution Commands

To execute the entire automated validation suite covering isolated routing, components widgets, static data constraints, local logging format, and non-regression checks, run:

```bash
# Execute full test suite
flutter test test/patient_view/

# Run static analyzer
flutter analyze lib/
```

### Expected Output
All tests must execute successfully with zero failures and warnings:
```
00:02 +8: All tests passed!
```

---

## 3. Architecture Isolation Checklist

The patient-facing layer is built as a fully isolated, additive clinical package. Verify that no file in `lib/screens/patient_view/` or `lib/components/patient_view/` imports any of the following clinician/DB services:

- [x] No `package:firebase_auth/firebase_auth.dart` imports.
- [x] No `package:cloud_firestore/cloud_firestore.dart` imports.
- [x] No clinician Screens imports (`lib/Screens/Home/` or `lib/Screens/Welcome/`).
- [x] No clinician Service providers (`lib/Services/auth.dart` or `lib/Services/database.dart`).
- [x] No chatbot imports (`lib/chatbot/`).

*This is verified programmatically on every run of `flutter test test/patient_view/isolation_test.dart`.*

---

## 4. Manual Verification Checklist

Follow this checklist during manual runs to ensure split and logging validity:

### Step 1: Enroll Participant
- [ ] Run with flag `MODE=patient`.
- [ ] Verify setup screen renders with text input.
- [ ] Toggle the persistent language switcher in the AppBar and verify the entire setup layout translates dynamically.
- [ ] Input participant ID (e.g. `P05`) and select **Pictures + Voice** (Condition A) or **Basic Text Table** (Condition B). Click **Launch Study**.

### Step 2: Test Condition A (Pictures + Voice Guidance)
- [ ] Verify that Medication 1 renders.
- [ ] Verify that the stepper dot indicator highlights step 1.
- [ ] Verify that the anatomy diagram is loaded and displays a highlight in the upper abdomen.
- [ ] Tap the **Language Toggle** (English/తెలుగు) and verify the text fields and clinical values immediately change languages.
- [ ] Tap **Listen** and verify audio voice speaks clearly.
- [ ] Tap **Answer questions about this medicine**, submit answers to the 6 high-value quiz questions, and verify that the app returns cleanly to the stepper list.

### Step 3: Test Condition B (Basic Text Instructions)
- [ ] Exit the session, start a new one, and select **Basic Text Table**. Click **Launch Study**.
- [ ] Verify that no anatomy diagrams or listen buttons are rendered.
- [ ] Verify that a simple clinical table is presented containing fields `Medicine`, `Dose`, `Route`, `Frequency`, and `Purpose`.
- [ ] Verify that tapping the Language Toggle changes both labels and clinical details values dynamically into Telugu.
- [ ] Complete the 6 quiz questions.

### Step 4: Verify Session Log Export
- [ ] On the setup screen, tap the download icon in the top right.
- [ ] Verify a SnackBar displays the local export path.
- [ ] Open the generated `.csv` or `.json` file and verify all answers, correct flags, screen times, and language codes are recorded accurately.

---

## 5. Core Value-Bringing Features

The following features represent the most significant additions to the patient layer, driving direct value in usability, reliability, and accessibility:

1. **Voice Support (Text-to-Speech)**
   - Utilizes `flutter_tts` to read out medication instructions, making the application accessible to users with visual impairments or lower literacy levels.

2. **Repetition of Explanation**
   - An interactive, patient-centric design where the system repeats and reinforces complex medical explanations if the user indicates they do not fully understand the material.

3. **Robust Test Suite**
   - Comprehensive automated testing (UI, accessibility, and performance) ensuring high stability and a regression-free environment across future updates.

4. **Low Network Support**
   - Engineered with resilient data caching mechanisms to ensure that the patient experience remains uninterrupted even in environments with poor or fluctuating internet connectivity.

5. **No-Hang Features (Performance Optimization)**
   - Background processing and strict state management ensure the main UI thread is never blocked, preventing UI freezes (hangs) during complex operations or media playback, verified continuously by the `performance_tracker`.
