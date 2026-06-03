# VEWHA Patient Layer Redesign & Stabilization

## Architecture Pivot
Based on acceptance testing and instructor feedback, the previous "cosmetic-first" animation approach was discarded. The UI has been stabilized to focus on comprehensive, highly synchronized multimodal learning (visual + text + audio) for low-literacy users.

## Key Changes
1. **Restored Textual Mechanisms:** The step-by-step mechanism text (`MechanismAnimator`) was restored but now operates in perfect synchronization with the visual mechanism animation and audio TTS.
2. **TTS Chunked Synchronization:** `PatientTtsService` was upgraded to include `speakChunked`, allowing discrete `speak()` calls for each mechanism step. This accurately triggers the visual node highlight on the exact spoken step.
3. **Anatomy Viewer Scale:** The `AnatomyViewer` now uses `MediaQuery.of(context).size.height * 0.40` for its baseline layout, providing a massive increase in visibility.
4. **Enhanced Visual Contrast:** `_MechanismPainter` alpha layers and stroke widths were increased substantially to ensure highlights pop against the base SVG illustrations.
5. **MCQ Clipping Resolved:** Forced `Expanded` and `softWrap: true` on all quiz text options for Telugu, Hindi, and English.
6. **Asset Reuse Strategy:** Avoided redundant animations by integrating `Lottie.asset` dynamically from the existing `assets/animations` folder directly into the updated `MechanismAnimator`.

## Known Limitations
- Audio Replay functionality attempts to restart from the beginning of the paused chunk, which may feel slightly abrupt compared to a native `seek` implementation (which `FlutterTts` does not natively support).

## Accessibility Additions
- TTS controls are strictly `>= 48x48` bounds.
- Added dynamic "Replay" options once the animation completes.
