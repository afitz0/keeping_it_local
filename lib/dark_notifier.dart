import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

final host = "http://localhost:8080";

class PrefsState {
  final bool darkMode;

  const PrefsState({this.darkMode = false});
}

class DarkNotifier with ChangeNotifier {
  PrefsState _currentPrefs = PrefsState(darkMode: false);

  DarkNotifier() {
    _loadDarkPref();
  }

  bool get isDark => _currentPrefs.darkMode;

  set darkMode(bool newValue) {
    if (newValue == _currentPrefs.darkMode) return;
    _currentPrefs = PrefsState(darkMode: newValue);
    notifyListeners();
    _saveDarkPref();
  }

  Future<void> _loadDarkPref() async {
    // await SharedPreferences.getInstance().then((prefs) {
    //   bool darkPref = prefs.getBool('isDarkMode') ?? false;
    //   _currentPrefs = PrefsState(darkMode: darkPref);
    // });

    final response = await http.Client().get(host + '/prefs');
    final parsed = jsonDecode(response.body);
    _currentPrefs = PrefsState(darkMode: parsed["dark"]);

    notifyListeners();
  }

  Future<void> _saveDarkPref() async {
    // await SharedPreferences.getInstance().then((prefs) {
    //   prefs.setBool('userDarkMode', _currentPrefs.darkMode);
    // });

    await http.Client()
        .get(host + '/prefs?set=' + _currentPrefs.darkMode.toString());
  }
}
