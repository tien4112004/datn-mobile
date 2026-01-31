import 'package:AIPrimary/core/shared_preference/shared_preferences_pod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final generationPreferencesServiceProvider =
    Provider<GenerationPreferencesService>((ref) {
      final sharedPrefs = ref.watch(sharedPreferencesPod).requireValue;
      return GenerationPreferencesService(sharedPrefs);
    });

class GenerationPreferencesService {
  static const _keyPresentationThemeId =
      'generation_pref_theme_id'; // Kept old key for backward compatibility
  static const _keyPresentationTextModelId =
      'generation_pref_presentation_text_model_id';
  static const _keyPresentationLanguage =
      'generation_pref_presentation_language';
  static const _keyPresentationImageModelId =
      'generation_pref_presentation_image_model_id';
  static const _keyImageGenerateModelId =
      'generation_pref_image_generate_model_id';
  static const _keyMindmapTextModelId = 'generation_pref_mindmap_text_model_id';
  static const _keyMindmapLanguage = 'generation_pref_mindmap_language';
  static const _keyAppLocale = 'generation_pref_app_locale';

  final SharedPreferences _sharedPrefs;

  GenerationPreferencesService(this._sharedPrefs);

  // --- Presentation ---

  Future<void> savePresentationThemeId(String themeId) async {
    await _sharedPrefs.setString(_keyPresentationThemeId, themeId);
  }

  String? getPresentationThemeId() {
    return _sharedPrefs.getString(_keyPresentationThemeId);
  }

  Future<void> savePresentationTextModelId(int modelId) async {
    await _sharedPrefs.setInt(_keyPresentationTextModelId, modelId);
  }

  int? getPresentationTextModelId() {
    return _sharedPrefs.getInt(_keyPresentationTextModelId);
  }

  Future<void> savePresentationLanguage(String language) async {
    await _sharedPrefs.setString(_keyPresentationLanguage, language);
  }

  String? getPresentationLanguage() {
    return _sharedPrefs.getString(_keyPresentationLanguage);
  }

  Future<void> savePresentationImageModelId(int modelId) async {
    await _sharedPrefs.setInt(_keyPresentationImageModelId, modelId);
  }

  int? getPresentationImageModelId() {
    return _sharedPrefs.getInt(_keyPresentationImageModelId);
  }

  // --- Image Generation ---

  Future<void> saveImageGenerateModelId(int modelId) async {
    await _sharedPrefs.setInt(_keyImageGenerateModelId, modelId);
  }

  int? getImageGenerateModelId() {
    return _sharedPrefs.getInt(_keyImageGenerateModelId);
  }

  // --- Mindmap ---

  Future<void> saveMindmapTextModelId(int modelId) async {
    await _sharedPrefs.setInt(_keyMindmapTextModelId, modelId);
  }

  int? getMindmapTextModelId() {
    return _sharedPrefs.getInt(_keyMindmapTextModelId);
  }

  Future<void> saveMindmapLanguage(String language) async {
    await _sharedPrefs.setString(_keyMindmapLanguage, language);
  }

  String? getMindmapLanguage() {
    return _sharedPrefs.getString(_keyMindmapLanguage);
  }

  // --- App Locale ---

  Future<void> saveAppLocale(String locale) async {
    await _sharedPrefs.setString(_keyAppLocale, locale);
  }

  String? getAppLocale() {
    return _sharedPrefs.getString(_keyAppLocale);
  }
}
