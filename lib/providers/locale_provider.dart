import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider({SharedPreferences? prefs}) {
    _prefs = prefs;
    _loadLanguage();
  }

  SharedPreferences? _prefs;
  String _languageCode = 'en';
  bool _hasSelectedLanguage = false;

  String get languageCode => _languageCode;
  bool get isIndonesian => _languageCode == 'id';
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  Locale get locale => Locale(_languageCode);

  /// Returns [id] when Bahasa Indonesia is active, otherwise [en].
  String tr(String en, String id) => _languageCode == 'id' ? id : en;

  Future<void> _loadLanguage() async {
    _prefs ??= await SharedPreferences.getInstance();
    final savedCode = _prefs?.getString(AppConstants.prefKeyLanguageCode);
    final selected =
        _prefs?.getBool(AppConstants.prefKeyLanguageSelected) ?? false;
    if (savedCode != null && (savedCode == 'en' || savedCode == 'id')) {
      _languageCode = savedCode;
    }
    _hasSelectedLanguage = selected;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (code != 'en' && code != 'id') return;
    _languageCode = code;
    _hasSelectedLanguage = true;
    notifyListeners();

    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setString(AppConstants.prefKeyLanguageCode, code);
    await _prefs?.setBool(AppConstants.prefKeyLanguageSelected, true);
  }
}

