# VEWHA Module-Level Architecture Analysis

This document contains a codebase-driven, fine-grained architectural analysis of the VEWHA project, derived directly from the current implementation.

## Phase 1 — Repository Analysis Summary

The VEWHA repository is a dual-mode Flutter application controlled by environment variables at compile-time (`MODE=patient`). 
The hierarchy enforces a strict separation between a **Firebase-dependent Clinician Mode** and an **Offline-first Patient Mode**.

* **Root**: `lib/main.dart` branches execution.
* **Clinician Modules**: `lib/Screens/Login`, `Welcome`, `Signup`, `Home` (EHR, Calendar, Chatbot). Handled by `lib/Services/auth.dart` and `database.dart`.
* **Patient Modules**: `lib/Screens/patient_view/` (Entry, List, Detail, PlainText, Comprehension).
* **Patient Components**: `lib/components/patient_view/` (AnatomyViewer, MechanismAnimator, AudioNarration, etc.).
* **Patient Services**: `PatientTtsService`, `TranslationService`.
* **Data & Configuration**: `lib/data/` (prescriptions.dart, anatomy_config.dart, plain_lang_entry.dart).
* **Logging & Export**: `lib/logging/` (StudyLogger, PerformanceTracker).
* **Assets**: `assets/anatomy/` (SVGs), `assets/i18n/` (JSON dictionaries).

## Phase 2, 3 & 4 — Module Identification & Responsibilities

1. **Presentation Layer**: 
   - **Clinician**: `home_page`, `calendar`, `chatbot_page`, `add_patient`, `EHR`.
   - **Patient**: `patient_entry_screen`, `medication_list_screen`, `medication_detail_screen` (Condition A), `plain_text_condition_screen` (Condition B), `comprehension_screen`.
2. **Animation Engine**: `AnatomyViewer` (SVG parsing, CustomPainter rendering wrapped in RepaintBoundary), `MechanismAnimator` (staggered text reveals).
3. **Audio Master Clock**: `PatientTtsService` acts as the master clock via `Stopwatch` and `ValueNotifier<Duration> currentChunkPosition`.
4. **Translation Pipeline**: `TranslationService` lazy-loads `assets/i18n/*.json` and applies a `MedicalGlossary` interceptor to fix literal translations.
5. **Data & Domain Models**: `StudyDrug`, `PlainLangEntry`, `AnatomyAnimationConfig`.
6. **Persistence & Export**: `StudyLogger` accumulates `LogEntry` in memory and exports to CSV via `path_provider` and `share_plus`.

---

## Phase 9 & 10 — Mermaid Diagrams

### Diagram 1: Complete Module Architecture
*This diagram maps the physical folder structure and module boundaries of the entire application.*

```mermaid
graph TD
    App["VEWHA App (main.dart)"]

    subgraph ClinicianMode["Clinician Mode (Online)"]
        direction TB
        C_Auth["Login / Signup / Welcome"]
        C_Home["Home Dashboard"]
        C_EHR["EHR & Patient Management"]
        C_Chat["Chatbot API"]
        C_Cal["Calendar"]
    end

    subgraph PatientMode["Patient Mode (Offline)"]
        direction TB
        P_Nav["PatientEntryScreen"]
        P_List["MedicationListScreen"]
        P_CondA["MedicationDetailScreen"]
        P_CondB["PlainTextConditionScreen"]
        P_Comp["ComprehensionScreen"]
    end

    subgraph CoreServices["Shared & Core Services"]
        direction TB
        S_Firebase["AuthMethods & DatabaseMethods"]
        S_Audio["PatientTtsService"]
        S_Trans["TranslationService"]
        S_Log["StudyLogger"]
    end

    subgraph Components["Patient UI Components"]
        direction TB
        Comp_Ana["AnatomyViewer"]
        Comp_Mech["MechanismAnimator"]
        Comp_Aud["AudioNarration"]
        Comp_Pic["PictogramRow"]
    end

    subgraph DataStorage["Data & Assets"]
        direction TB
        D_Presc["prescriptions.dart"]
        D_I18n["assets/i18n/*.json"]
        D_SVG["assets/anatomy/*.svg"]
    end

    App --> ClinicianMode
    App --> PatientMode
    ClinicianMode --> S_Firebase
    PatientMode --> CoreServices
    PatientMode --> Components
    PatientMode --> DataStorage
```

---

### Diagram 2: Dependency Graph
*This graph illustrates the explicit `depends on` and `owns` relationships within the Patient View workflow.*

```mermaid
graph TD
    MedicationDetailScreen -- "owns state" --> _activeStepNotifier
    MedicationDetailScreen -- "depends on" --> TranslationService
    MedicationDetailScreen -- "depends on" --> AnatomyViewer
    MedicationDetailScreen -- "depends on" --> MechanismAnimator
    MedicationDetailScreen -- "depends on" --> AudioNarration
    
    TranslationService -- "loads" --> JSONAssets["assets/i18n/*.json"]
    TranslationService -- "creates" --> PlainLangEntry

    AnatomyViewer -- "depends on" --> PatientTtsService
    AnatomyViewer -- "uses" --> SVGAssets["assets/anatomy/*.svg"]
    AnatomyViewer -- "creates" --> MechanismPainter["_MechanismPainter"]
    
    AudioNarration -- "calls" --> PatientTtsService
    PatientTtsService -- "wraps" --> FlutterTts
    PatientTtsService -- "updates" --> currentChunkPosition["ValueNotifier<Duration>"]
    
    currentChunkPosition -- "drives" --> AnatomyViewer
    
    MechanismAnimator -- "listens to" --> _activeStepNotifier
```

---

### Diagram 3: Presentation Layer
*Displays the separation of navigation routes and state ownership across the two application modes.*

```mermaid
graph LR
    subgraph Clinician Routes
        Splash["/splash"] --> Login["/login"]
        Login --> Home["/home"]
        Home --> AddPat["/add_patient"]
        Home --> EHR["/EHR"]
        Home --> Chat["/chatbot"]
    end

    subgraph Patient Routes
        Entry["/patient_entry"] --> MedList["/med_list"]
        MedList -- "Condition A" --> MedDetail["/med_detail"]
        MedList -- "Condition B" --> PlainText["/plain_text"]
        MedDetail --> CompScreen["/comprehension"]
        PlainText --> CompScreen["/comprehension"]
    end

    FirebaseState["Firebase Auth State"] -.-> Clinician Routes
    SessionState["StudyLogger Session State"] -.-> Patient Routes
```

---

### Diagram 4: Business Logic Layer
*Shows the isolated logic providers and singletons that handle core business rules without UI mixing.*

```mermaid
graph TB
    subgraph Clinician Business Logic
        AuthMethods["AuthMethods (GoogleSignIn, Firebase)"]
        DBMethods["DatabaseMethods (Firestore CRUD)"]
        GeminiAPI["Chatbot HTTP Calls"]
    end

    subgraph Patient Business Logic
        TTSLog["PatientTtsService<br>(Audio Clock, TTS State)"]
        TransLog["TranslationService<br>(Glossary Interceptor, LRU Cache)"]
        StudyLog["StudyLogger<br>(UUID Session, CSV Builder)"]
    end

    classDef service fill:#f9f,stroke:#333,stroke-width:2px;
    class AuthMethods,DBMethods,TTSLog,TransLog,StudyLog service;
```

---

### Diagram 5: Animation System
*Highlights the specific internal rendering pipeline for the physiology animations.*

```mermaid
graph TD
    Tick["ValueListenableBuilder<br>(Tick from Audio Clock)"]
    Config["AnatomyAnimationConfig<br>(Coordinates & Timing)"]
    Painter["CustomPainter (_MechanismPainter)"]
    Repaint["RepaintBoundary<br>(Layout Isolation)"]
    SVG["Static SVG Background<br>(Opacity: 0.8)"]
    Canvas["Canvas.drawPath() & drawCircle()"]

    Tick --> Painter
    Config --> Painter
    Painter --> Canvas
    SVG --> Repaint
    Painter --> Repaint
```

---

### Diagram 6: Audio System
*Traces the master clock synchronization pipeline created during the recent refactor.*

```mermaid
sequenceDiagram
    participant UI as AudioNarration UI
    participant TTS as PatientTtsService
    participant Engine as FlutterTts Native
    participant Clock as Stopwatch & Timer
    participant Anim as AnatomyViewer (SVG)

    UI->>TTS: speakChunked()
    TTS->>Engine: setLanguage & speak
    Engine-->>TTS: Start Handler Triggered
    TTS->>Clock: start()
    loop Every 16ms
        Clock-->>TTS: update currentChunkPosition
        TTS-->>Anim: Notify Listeners
        Anim->>Anim: Calculate Frame (t = ms % 2500)
    end
    Engine-->>TTS: Pause/Complete Handler
    TTS->>Clock: stop() / reset()
    Clock-->>Anim: Freeze Frame
```

---

### Diagram 7: Translation System
*Maps the localization pipeline, proving no hardcoded maps remain.*

```mermaid
graph LR
    UI["MedicationDetailScreen<br>Language Dropdown"]
    TS["TranslationService"]
    File["assets/i18n/{lang}.json"]
    Glossary["MedicalGlossary Interceptor"]
    Model["PlainLangEntry Model"]

    UI -- "request lang" --> TS
    TS -- "File I/O" --> File
    File -- "Raw JSON" --> TS
    TS -- "Apply Corrections (e.g., Sugar -> Diabetes)" --> Glossary
    Glossary -- "Clean Strings" --> TS
    TS -- "Deserialize" --> Model
    Model -- "Update State" --> UI
```

---

### Diagram 8: CSV Export System
*Shows the completely offline storage and share pipeline for clinical study logging.*

```mermaid
graph TD
    Action["User taps Export"]
    Logger["StudyLogger Singleton"]
    Data["List<LogEntry>"]
    CSV["CSV Builder logic"]
    Path["path_provider (App Docs Dir)"]
    Share["share_plus Native UI"]

    Action --> Logger
    Logger --> Data
    Data --> CSV
    CSV --> Path
    Path -- "File Path" --> Share
    Share -- "Share Sheet (AirDrop/Email)" --> OS["Operating System"]
```

---

### Diagram 9: State Management
*Illustrates who owns state and how it cascades to child widgets in Patient Mode.*

```mermaid
graph TD
    subgraph Screen State (StatefulWidget)
        MedDetail["MedicationDetailScreen"]
        MedDetail -- "owns" --> lang["_lang (String)"]
        MedDetail -- "owns" --> loading["_isLoading (bool)"]
        MedDetail -- "owns" --> audioPlayed["_audioPlayed (bool)"]
        MedDetail -- "owns" --> activeStep["_activeStepNotifier<br>(ValueNotifier)"]
    end

    subgraph Service State (Singletons)
        TTS["PatientTtsService"] -- "owns" --> ttsState["stateNotifier (playing/paused)"]
        TTS -- "owns" --> clock["currentChunkPosition (Duration)"]
        
        Trans["TranslationService"] -- "owns" --> cache["_cache (Map)"]
        
        Log["StudyLogger"] -- "owns" --> session["_sessionId, _entries"]
    end

    activeStep -. "listened by" .-> MechanismAnimator
    activeStep -. "listened by" .-> AnatomyViewer
    clock -. "listened by" .-> AnatomyViewer
    ttsState -. "listened by" .-> AudioNarration
```

---

### Diagram 10: End-to-End Runtime Flow
*A complete behavioral flow of a patient session from start to export.*

```mermaid
stateDiagram-v2
    [*] --> PatientEntryScreen
    PatientEntryScreen --> SetupSession: Enter Code
    SetupSession --> MedicationListScreen: Logger init
    
    state MedicationListScreen {
        [*] --> SelectConditionA
        [*] --> SelectConditionB
    }
    
    SelectConditionA --> MedicationDetailScreen
    SelectConditionB --> PlainTextConditionScreen
    
    state MedicationDetailScreen {
        LazyLoadJSON --> RenderUI
        RenderUI --> ReadAudio
        ReadAudio --> AudioSyncsVisuals
        AudioSyncsVisuals --> ComprehensionTest
    }
    
    state PlainTextConditionScreen {
        ReadText --> ComprehensionTest
    }
    
    ComprehensionTest --> MCQ_Evaluation
    MCQ_Evaluation --> LogResults
    LogResults --> PatientEntryScreen: Return
    
    PatientEntryScreen --> CSVExport: Tap Export
    CSVExport --> ShareSheet
    ShareSheet --> [*]
```

## Phase 8 & Final Validation

**State Ownership Breakdown:**
* **Language**: Owned locally by `_MedicationDetailScreenState` (and passed down) and globally cached by `TranslationService`.
* **Playback**: Owned entirely by `PatientTtsService`.
* **Animation Progress**: Computed directly from `PatientTtsService.currentChunkPosition`.
* **Session/Export**: Owned by `StudyLogger`.
* **Medication Selection**: Passed as immutable `StudyDrug` arguments down the navigation stack.

**Validation Confirmations:**
I validate that this architecture strictly reflects the current codebase implementation resulting from the recent refactor. 
- It accurately represents the separation of Firebase (Clinician) and Local-Only (Patient) modes.
- It proves the removal of `plain_language_map.dart` in favor of `assets/i18n` lazy loading.
- It documents the `ValueListenableBuilder` audio-clock synchronization in `AnatomyViewer`.
- It accurately diagrams the `StudyLogger` CSV export connecting to `share_plus`.
