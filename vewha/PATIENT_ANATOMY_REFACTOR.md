# Patient Anatomy & Comprehension Refactor

## Overview
This document outlines the changes made to the patient-facing layer to fix UI/UX issues, enhance comprehension through better visualization, and ensure extensibility for future studies.

## 1. Anatomy Engine Refactor (`anatomy_viewer.dart` & `anatomy_config.dart`)
- **Rationale for removing `body.mp4`**: The static video approach was not extensible. It could not easily highlight specific organs, synchronize precisely with varied step counts, or be reused for new medications without creating new video assets.
- **Data-Driven Architecture**: The anatomy visualization is now driven by `AnatomyAnimationConfig`. Each medication defines its own `organTargets`, `animationPaths`, and `narrationSyncPoints`.
- **SVG Layered Rendering**: `AnatomyViewer` loads a base SVG (e.g., `endocrine.svg`, `respiratory.svg`) corresponding to the drug's `BodySystem`.
- **Dynamic Mechanism Painter**: `_MechanismPainter` renders the highlights and flow particles based on normalized screen coordinates (`0.0` to `1.0`) defined in the configuration, automatically scaling to any screen size.
- **Future Extension Process**: To add a new medication, a developer only needs to define a new `AnatomyAnimationConfig` object in `prescriptions.dart` (specifying SVG coordinate targets and paths). No custom painter code or new MP4 videos are required.

## 2. Dynamic Mechanism Storyboard (`mechanism_animator.dart`)
- **Meaningful Icons**: Replaced abstract numbered circles (1, 2, 3, 4) with clear visual indicators using `MechanismStep`.
- **Vector Assets**: The storyboard uses recognizable Material Symbols (e.g., Tablet, Lungs, Blood vessels) to help illiterate patients translate the mechanism into physical reality.
- **Synchronization**: The storyboard actively drives the educational experience. As the `activeStepNotifier` increments, the corresponding storyboard icon highlights, the relevant anatomy region glows, the pathway animates, and the TTS audio plays.

## 3. MCQ Crash Fix (`comprehension_screen.dart`)
- **BoxConstraints Resolved**: Fixed a critical crash where `ElevatedButton` sizing conflicted with intrinsic layout constraints (`minWidth > maxWidth`).
- **Dynamic Height**: Removed `minimumSize` from the button style and applied a minimum height of 60px directly to a child `Container`. 
- **Multilingual Wrapping**: English, Telugu, and Hindi strings can now wrap infinitely without clipping, truncation, or layout exceptions.

## Validation
Please refer to `PATIENT_LAYER_VALIDATION.md` for updated manual testing steps.
