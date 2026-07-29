# Engineering Report: VEWHA Final Architecture Refactor

## Executive Summary
This report outlines the completion of the 14-phase refactoring initiative designed to make the VEWHA medical education platform scalable, extensible, and enterprise-ready. The changes heavily focused on data externalization, internationalization (i18n), decoupling animations from audio, and implementing clean architecture principles (Presentation -> Services -> Repositories -> Assets).

## Key Accomplishments

### 1. Data Schema Externalization (Phases 1, 2, 3, 7, 8, 9, 11)
- **Problem**: Previously, drug mechanisms, metadata, and anatomy configurations were hardcoded in Dart (`prescriptions.dart`), making it difficult to maintain and scale without recompiling the application. 
- **Solution**: We fully externalized structural drug data into `assets/data/prescriptions.json`. We created `DataRepository` to deserialize this data lazily upon application boot.
- **UI Localization**: String literals embedded in UI files were extracted into `assets/i18n/ui_*.json` files. 
- **LocalizationRepository**: The `LocalizationRepository` was rebuilt to handle independent namespaces:
  - `getUiString(key)` for short labels
  - `getClinicalEntry(drugKey)` for long-form medical explanations
  - `getQuizString(questionKey)` for MCQs.
  - Built-in fallback chains guarantee that missing translations default safely to English.

### 2. Audio & TTS Optimization (Phase 4)
- **Problem**: The TTS engine introduced a slight start latency, causing audio to lag slightly behind the visual storyboard.
- **Solution**: The `prewarm()` method in `PatientTtsService` was upgraded to synthesize a silent audio frame (`<speak><break time="1ms"/></speak>`) with 0.0 volume immediately upon initialization. This forces the native OS to load the TTS voice buffer into memory before the user ever initiates a playback action, significantly reducing startup latency.

### 3. Animation Decoupling & Synchronization (Phases 5, 6)
- **Problem**: The mechanism visual animations were tightly coupled to the TTS audio clock, which meant pausing audio froze the animation, and unexpected audio latencies disrupted the visual timeline.
- **Solution**: 
  - **Decoupling**: `AnatomyViewer` was detached from the audio clock. It now uses an internal repeating `AnimationController` (`_loopController`).
  - **Continuous Loop**: The animation runs continuously to show dynamic blood flow, particle traversal, etc., regardless of the audio state.
  - **Interaction Sync**: We exposed `restartAnimation()` via a `GlobalKey<AnatomyViewerState>` in the `MedicationDetailScreen`. Whenever the user initiates the "Listen" action (or when audio replays), the UI simultaneously resets the `AnatomyViewer`'s animation to `t=0`, perfectly syncing the start of the audio with the start of the visual loop.

### 4. Clean Architecture (Phases 10, 12, 13, 14)
- Hardcoded Dart models were stripped out in favor of dynamic JSON loading.
- We implemented `DataRepository` and `LocalizationRepository` at the top level in `main.dart` using the `Provider` pattern.
- A final architectural diagram (`final_architecture.md`) was generated to map the clean separations of concern.

## Root Causes Resolved
1. **OOM Risks / Bloat**: Dart files with large arrays of string definitions take up permanent heap memory. JSON assets are only loaded when needed.
2. **Animation Desync**: Relying on OS TTS progress updates (which can be fired unevenly on low-end Android devices) caused choppy animations. A Flutter-native `AnimationController` ensures steady 60fps animations, only needing a sync pulse at the start of interactions.
3. **Missing Translation Crashes**: Hardcoded translations that were missing could result in null pointer exceptions or blank UIs. The new `LocalizationRepository` enforces a strict fallback layer.

## Future Recommendations
- Implement a mechanism to fetch `prescriptions.json` updates from a remote CDN/backend to allow content updates without releasing a new app version.
- Introduce unit tests targeting the `DataRepository` parsing logic to ensure changes to the JSON schema don't break serialization.
