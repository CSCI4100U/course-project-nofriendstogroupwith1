import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:group_project/models/settings_model.dart';
import 'package:group_project/views/home_page.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SettingsModel _settingsModel = SettingsModel();

  bool _pushNotifications = true;
  bool _autoSave = true;
  bool _12Hour = false;
  String _language = "en-US";

  Future<void> getUpdatedSettings() async {
    _autoSave =
        await _settingsModel.getBoolSetting(SettingsModel.settingAutoSave) ??
            true;
    _language =
        await _settingsModel.getStringSetting(SettingsModel.settingLanguage) ??
            'en-US';
    _12Hour =
        await _settingsModel.getBoolSetting(SettingsModel.setting12Hour) ??
            false;
    _pushNotifications = await _settingsModel
            .getBoolSetting(SettingsModel.settingNotifications) ??
        true;
  }

  Widget _buildSetting({String label = "", required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          child,
        ],
      ),
    );
  }

  Widget _buildToggleSetting({String label = "",bool value = false,
                            required void Function(bool)? onChanged}) {
    return _buildSetting(
      label: label,
      child: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildSettingHeader(String _text) {
    return Padding(
        padding: const EdgeInsets.only(
            top: 32.0, left: 16.0, bottom: 16.0, right: 16.0),
        child: Text(
          _text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUpdatedSettings(),
        builder: (context, snapshot) {
          return ListView(
            children: [
              _buildSettingHeader(FlutterI18n.translate(context, "settings.general.heading")),
              _buildToggleSetting(
                  label: FlutterI18n.translate(context, "settings.general.autoSave"),
                  value: _autoSave,
                  onChanged: (value) {
                    setState(() {
                      _autoSave = value;
                      _settingsModel.setBoolSetting(
                          name: SettingsModel.settingAutoSave, value: value);
                    });
                  }),
              _buildToggleSetting(
                  label: FlutterI18n.translate(context, "settings.general.12hour"),
                  value: _12Hour,
                  onChanged: (value) {
                    setState(() {
                      _12Hour = value;
                      _settingsModel.setBoolSetting(
                          name: SettingsModel.setting12Hour, value: value);
                    });
                  }),
              _buildToggleSetting(
                  label: FlutterI18n.translate(context, "settings.general.notify"),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                      _settingsModel.setBoolSetting(
                          name: SettingsModel.settingNotifications,
                          value: value);
                    });
                  }),
              _buildSettingHeader(FlutterI18n.translate(context, "settings.localization.heading")),
              _buildSetting(
                label: FlutterI18n.translate(context, "settings.localization.language"),
                child: DropdownButton(
                    value: _language,
                    items: const [
                      DropdownMenuItem(
                        value: "en-US",
                        child: Text(
                          "🇺🇸 English (US)",
                          textAlign: TextAlign.end,
                        ),
                      ),
                      DropdownMenuItem(
                        value: "en-UK",
                        child: Text(
                          "🇬🇧 English (UK)",
                          textAlign: TextAlign.end,
                        ),
                      ),
                      DropdownMenuItem(
                        value: "fr-FR",
                        child: Text(
                          "🇫🇷 Français (FR)",
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          _language = value;
                          _settingsModel.setStringSetting(
                              name: SettingsModel.settingLanguage,
                              value: value);
                          List<String> lang = _language.split('-');
                          HomePage.setLanguage(context, Locale(lang[0], lang[1]));
                        }
                      });
                    }),
              ),
              _buildSettingHeader(FlutterI18n.translate(context, "settings.legal.heading")),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                          onPressed: () {
                            showAboutDialog(
                              context: context,
                              applicationIcon: const FlutterLogo(),
                              applicationName: "Post It, Pin It",
                              applicationVersion: "1.0.0",
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Column(
                                    children: const [
                                      Text("This app was created by:"),
                                      ListTile(title: Text("Alexander Naylor"), subtitle: Text("Maps and Geolocation"),),
                                      ListTile(title: Text("Dylan Moore"), subtitle: Text("Database and Local Storage"),),
                                      ListTile(title: Text("Sukhpreet Bansal"), subtitle: Text("Dialogs and Snackbars"),),
                                      ListTile(title: Text("Hamza Khan"), subtitle: Text("Camera and Post Creation"),),
                                    ],
                                  ),
                                ),
                              ],
                              applicationLegalese:
                                  "Copyright 2022 © Alexander Naylor, Dylan Moore, Sukhpreet Bansal and Hamza Khan.",
                            );
                          },
                          child: Text(FlutterI18n.translate(context, "settings.legal.about"))
                        ),
                  )
                ],
              ),
            ],
          );
        });
  }
}
