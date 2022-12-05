import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_project/models/settings_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SettingsModel _settingsModel = SettingsModel();

  bool _autoSave = true;
  String _language = "en-US";

  Future<void> getUpdatedSettings() async {
    _autoSave =
        await _settingsModel.getBoolSetting(SettingsModel.settingAutoSave) ??
            true;
    _language =
        await _settingsModel.getStringSetting(SettingsModel.settingLanguage) ??
            'en-US';
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

  Widget _buildToggleSetting(
      {String label = "",
      bool value = false,
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
              _buildSettingHeader("General"),
              _buildToggleSetting(
                  label: "Auto-save added posts",
                  value: _autoSave,
                  onChanged: (value) {
                    setState(() {
                      _autoSave = value;
                      _settingsModel.setBoolSetting(
                          name: SettingsModel.settingAutoSave, value: value);
                    });
                  }),
              _buildSettingHeader("Localization"),
              _buildSetting(
                label: SettingsModel.settingLanguage,
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
                          "🇫🇷 French (FR)",
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
                        }
                      });
                    }),
              ),
              _buildSettingHeader("Legal"),
              _buildSetting(
                  label: "Details",
                  child: ElevatedButton(
                      onPressed: () {
                        showAboutDialog(
                          context: context,
                          applicationName: "Post It, Pin It",
                          applicationVersion: "4.1.2",
                          children: [
                            const Text(
                                "\nThis app is created by Alexander Naylor, Dylan Moore, Sukhpreet Bansal and Hamza Khan."),
                          ],
                          applicationLegalese:
                              "Copyright 2022 © Alexander Naylor, Dylan Moore, Sukhpreet Bansal and Hamza Khan.",
                        );
                      },
                      child: const Text("About")))
            ],
          );
        });
  }
}
