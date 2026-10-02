import 'package:flutter/material.dart';

enum SettingsAction { toggleMode, newList }

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Mode'),
            onTap: () {
              Navigator.of(context).pop(SettingsAction.toggleMode);
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('New List'),
            onTap: () {
              Navigator.of(context).pop(SettingsAction.newList);
            },
          ),
        ],
      ),
    );
  }
}
