import 'package:datn_mobile/core/shared_preference/shared_preferences_pod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the view preference (grid/list) for resources across the app
/// This is a reusable provider that can be used for any resource type
class ViewPreferenceNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  final String _resourceType;

  ViewPreferenceNotifier(this._prefs, this._resourceType)
    : super(_prefs.getBool(_getKeyForResource(_resourceType)) ?? false);

  static String _getKeyForResource(String resourceType) =>
      'view_pref_$resourceType';

  /// Toggles between grid (true) and list (false) view
  Future<void> toggle() async {
    state = !state;
    await _prefs.setBool(_getKeyForResource(_resourceType), state);
  }

  /// Sets the view preference explicitly
  /// [isGrid] - true for grid view, false for list view
  Future<void> setView(bool isGrid) async {
    state = isGrid;
    await _prefs.setBool(_getKeyForResource(_resourceType), isGrid);
  }

  /// Returns true if grid view is enabled, false if list view is enabled
  bool get isGridView => state;

  /// Returns true if list view is enabled, false if grid view is enabled
  bool get isListView => !state;
}

/// Family provider for view preference notifier per resource type
/// This returns the notifier instance
final viewPreferenceNotifierPod =
    StateNotifierProvider.family<ViewPreferenceNotifier, bool, String>((
      ref,
      param,
    ) {
      final prefs = ref.watch(sharedPreferencesPod).requireValue;
      return ViewPreferenceNotifier(prefs, param);
    });
