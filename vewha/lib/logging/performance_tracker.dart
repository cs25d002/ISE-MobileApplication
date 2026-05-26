// lib/logging/performance_tracker.dart
// Profiling module verification — registers whether SVG/TTS are loaded.

class PatientModuleRegistry {
  static bool isTtsInitialized = false;
  static bool isSvgInitialized = false;

  static void reset() {
    isTtsInitialized = false;
    isSvgInitialized = false;
  }
}
