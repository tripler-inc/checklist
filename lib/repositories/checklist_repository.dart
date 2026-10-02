import 'dart:convert';

import 'package:checklist/models/checklist_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistRepository {
  const ChecklistRepository();

  static const _itemsKey = 'checklist_items';

  Future<List<ChecklistItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_itemsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => ChecklistItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveItems(List<ChecklistItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_itemsKey, jsonString);
  }
}
