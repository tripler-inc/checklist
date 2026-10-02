import 'dart:convert';

import 'package:checklist/models/checklist_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistRepository {
  const ChecklistRepository();

  static const _itemsKey = 'checklist_items';
  static const _savedListsKey = 'checklist_saved_lists';

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

  Future<List<String>> loadSavedListNames() async {
    final savedLists = await _loadSavedLists();
    final names = savedLists.keys.toList()..sort();
    return names;
  }

  Future<void> saveNamedList(String name, List<ChecklistItem> items) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedLists = await _loadSavedLists();
    savedLists[trimmedName] = items.map((item) => item.text).toList();
    await prefs.setString(_savedListsKey, jsonEncode(savedLists));
  }

  Future<List<ChecklistItem>> loadNamedList(String name) async {
    final savedLists = await _loadSavedLists();
    final itemTexts = savedLists[name];

    if (itemTexts == null) {
      return [];
    }

    return itemTexts.map((text) => ChecklistItem(text, checked: false)).toList();
  }

  Future<Map<String, List<String>>> _loadSavedLists() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_savedListsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return decoded.map((key, value) {
        final items = (value as List<dynamic>).map((entry) => entry.toString()).toList();
        return MapEntry(key, items);
      });
    } catch (_) {
      return {};
    }
  }
}
