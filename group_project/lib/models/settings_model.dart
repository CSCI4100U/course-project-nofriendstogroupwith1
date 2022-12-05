import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel {

  Future<void> setStringSetting({required String name, required String value}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(name, value);
  }

  Future<void> setBoolSetting({required String name, required bool value}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(name, value);
  }

  Future<void> setIntSetting({required String name, required int value}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(name, value);
  }

  Future<String?> getStringSetting(String name) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(name);
  }

  Future<bool?> getBoolSetting(String name) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(name);
  }

  Future<int?> getIntSetting(String name) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(name);
  }

}