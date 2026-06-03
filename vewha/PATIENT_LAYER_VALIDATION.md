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

---

## 3. Architecture Isolation Checklist

The patient-facing layer is built as a fully isolated, additive clinical package. Verify that no file in `lib/screens/patient_view/` or `lib/components/patient_view/` imports any of the following clinician/DB services:

- [x] No `package:firebase_auth/firebase_auth.dart` imports.
- [x] No `package:cloud_firestore/cloud_firestore.dart` imports.
- [x] No clinician Screens imports (`lib/Screens/Home/` or `lib/Screens/Welcome/`).
- [x] No clinician Service providers (`lib/Services/auth.dart` or `lib/Services/database.dart`).
- [x] No chatbot imports (`lib/chatbot/`).

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
- [ ] Verify that the anatomy diagram is loaded (using dynamic video model) and occupies ~40% of the screen height with high-contrast custom organ overlays.
- [ ] Verify that the visual mechanism animation and text steps are present below the anatomy diagram.
- [ ] Verify that the generic organ icons have been removed from the storyboard and replaced by clear step numbers, and the connector uses a solid progress bar instead of a bouncing dot.
- [ ] Tap the **Language Toggle** (English/తెలుగు/हिन्दी) and verify the text fields, visual overlays, and clinical values change languages.
- [ ] Tap **Listen** and verify consolidated audio voice speaks clearly. Verify that as the audio plays, the mechanism animation steps and visual highlights synchronize precisely with the spoken words.
- [ ] Tap **Answer questions about this medicine**, submit answers to the 6 high-value quiz questions.
- [ ] Verify the MCQ answer buttons do not clip text when displaying long translated sentences.

### Step 3: Test Condition B (Basic Text Instructions)
- [ ] Exit the session, start a new one, and select **Basic Text Table**. Click **Launch Study**.
- [ ] Verify that no anatomy diagrams or listen buttons are rendered.
- [ ] Verify that a simple clinical table is presented containing fields `Medicine`, `Dose`, `Route`, `Frequency`, and `Purpose`.
- [ ] Verify that tapping the Language Toggle changes both labels and clinical details values dynamically.

### Step 4: Verify Session Log Export
- [ ] On the setup screen, tap the download icon in the top right.
- [ ] Verify a SnackBar displays the local export path.
- [ ] Open the generated `.csv` or `.json` file and verify all answers are recorded accurately.

---

## 5. Core Value-Bringing Features

1. **Synchronized Chunked TTS Engine (`PatientTtsService`)**
   - Implements `speakChunked` for precise, step-by-step narration synchronized with `MechanismAnimator` visual text nodes, providing unified multimodal learning.

2. **Expanded Physiology Overlays (`AnatomyViewer`)**
   - Scaled to 40% screen height with high-contrast alphas to clearly explain active drug mechanisms visually (e.g., stomach-to-liver paths) directly on the dynamic video model.

3. **Robust Test Suite**
   - Comprehensive automated testing (UI, accessibility, and performance) ensuring high stability.

4. **Hardened Option Selectors**
   - Clean auto-wrapping and flexible heights prevent clipping in English, Hindi, and Telugu on small devices, using unrestricted vertical containers.
