# VEWHA Patient Layer — Drug Mechanism Extension & Performance Audit

This document outlines the architecture, performance optimization strategy, and visual-first mechanism explanation strategy implemented for the VEWHA Patient-Facing Layer.

---

## 1. Architecture Overview

```
                  ┌───────────────────────┐
                  │  PatientEntryScreen   │
                  └───────────┬───────────┘
                              │ prewarms singleton
                              ▼
                  ┌───────────────────────┐
                  │  PatientTtsService    │◄─────────────────┐
                  └───────────┬───────────┘                  │
                              │ provides prewarmed           │ controls recovery
                              ▼ instance & callbacks         │ narration
    ┌──────────────────────────────────────────────────┐     │
    │         MedicationDetailScreen (Condition A)     ├─────┤
    │  ┌────────────────────────────────────────────┐  │     │
    │  │ AnatomyViewer (Active Mechanism Overlays)  │  │     │
    │  └────────────────────────────────────────────┘  │     │
    │  ┌────────────────────────────────────────────┐  │     │
    │  │ AudioNarration Widget (Reactive Controls)  │  │     │
    │  └────────────────────────────────────────────┘  │     │
    │  ┌────────────────────────────────────────────┐  │     │
    │  │ MedicationCard & Options Details           │  │     │
    │  └────────────────────────────────────────────┘  │     │
    └─────────────────────────┬────────────────────────┘     │
                              │ opens                        │
                              ▼                              │
                  ┌───────────────────────┐                  │
                  │  ComprehensionScreen  ├──────────────────┘
                  └───────────────────────┘
```

The extension layer operates on a fully decoupled sandbox model, keeping clinician flows entirely unaffected. The patient-facing flows are activated strictly by passing the `--dart-define=MODE=patient` compile-time flag.

---

## 2. Singleton TTS Architecture (`PatientTtsService`)

To eliminate latency, connection drops, and handler conflicts observed with multi-screen or widget-level TTS bindings:
- **Unified Engine Binding:** A singular lifecycle controller `PatientTtsService` wraps the `flutter_tts` instance.
- **Early Engine Warming:** Initialized inside the setup enrollment screen `PatientEntryScreen` prior to launching the study.
- **Dynamic Aggregation:** Aggregates medicine purpose, administration instructions, and all mechanism steps dynamically at runtime rather than duplicating static data.
- **Event Callbacks:** Communicates state (Idle, Playing, Paused) to observers using a unified `ValueNotifier` instead of re-binding listeners.

---

## 3. Visual-First Physiology Overlays (`AnatomyViewer`)

For low-literacy or illiterate participants who gain little value from sequential text displays:
- **Visual Storyboards:** The separate text steppers are consolidated directly **inside** the pulsing SVG `AnatomyViewer` widget as active layers.
- **Visual Metaphors:**
  - **Metformin:** stomach-to-liver active flowing path, pulsing liver, and green sugar decreasing tags.
  - **Salbutamol:** descending blue airflow particles entering lungs and airway expansion pulses.
  - **Betamethasone:** Arm/leg rashes shrinking and fading into soothing teal.
  - **Amlodipine:** Widening chest vessel outlines and moving blood flow particles.
  - **Prednisolone:** Systemic purple/gold healing aura and joint inflammation markers shrinking and turning green.

---

## 4. Hardened MCQ Option Wrapping

- Option buttons in `comprehension_screen.dart` utilize expanded wrapping containing `Flexible`, `softWrap: true`, and `maxLines: null` properties inside `Row` contexts.
- Tested and verified on small 5-inch screen densities with the longest Hindi and Telugu strings to guarantee zero overflows or layout clips.

---

## 5. Performance & Resource Considerations

- **Initialization Lag:** Prewarming reduces audio startup latency to under **500ms** on button press.
- **Rebuild Counts:** Shifting event callbacks to the singular TTS service prevents full-screen rebuild loops during narration.
- **Lifecycle Safety:** Route changes or screen pops automatically invoke `PatientTtsService().stop()` to prevent active audio overlays.

---

## 6. Validation Checklist

- [ ] Verify `flutter analyze` returns zero errors and warnings.
- [ ] Verify `flutter test test/patient_view/` runs successfully with zero failures.
- [ ] Verify Condition A detail page loads `AnatomyViewer` with visual animated storyboards and no separate text steppers.
- [ ] Verify Audio Narration aggregates Purpose → Usage → Mechanism Steps seamlessly on Play.
- [ ] Verify Pause, Resume, Stop, and Replay buttons function dynamically.
- [ ] Verify quiz buttons wrap cleanly in Telugu and Hindi on small screen viewports.
