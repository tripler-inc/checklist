import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _version = '1.0';

  static const String _aboutText =
      'Checklist helps you create and manage reusable lists with persistent storage. '
      'You can add items, edit item text, check and uncheck tasks, reorder by long-press drag, '
      'and delete items with swipe gestures. Saved Lists lets you save named templates, load them '
      'with unchecked items, rename by long-pressing an existing file name, and delete saved files '
      'with swipe confirmation. Settings provides quick mode switching and New List reset behavior.';

  String _formatTodayDate() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final compileDate = _formatTodayDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Checklist',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _aboutText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Version'),
            subtitle: Text(_version),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Last compile date'),
            subtitle: Text(compileDate),
          ),
        ],
      ),
    );
  }
}
