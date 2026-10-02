import 'package:checklist/models/checklist_item.dart';
import 'package:checklist/repositories/checklist_repository.dart';
import 'package:checklist/widgets/checklist_input_bar.dart';
import 'package:checklist/widgets/checklist_item_tile.dart';
import 'package:checklist/widgets/edit_item_dialog.dart';
import 'package:flutter/material.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({
    super.key,
    this.onToggleTheme,
    ChecklistRepository? repository,
  }) : _repository = repository ?? const ChecklistRepository();

  final VoidCallback? onToggleTheme;
  final ChecklistRepository _repository;

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final List<ChecklistItem> _items = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final loadedItems = await widget._repository.loadItems();
    setState(() {
      _items
        ..clear()
        ..addAll(loadedItems);
    });
  }

  Future<void> _saveItems() {
    return widget._repository.saveItems(_items);
  }

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _items.add(ChecklistItem(text));
    });
    _controller.clear();
    _saveItems();
  }

  void _toggleItem(int index, bool? value) {
    setState(() {
      _items[index].checked = value ?? false;
    });
    _saveItems();
  }

  Future<void> _editItemText(int index) async {
    final result = await showEditItemDialog(context, _items[index].text);

    if (result != null && result.isNotEmpty) {
      setState(() {
        _items[index].text = result;
      });
      _saveItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          ChecklistInputBar(
            controller: _controller,
            onAdd: _addItem,
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _items.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
                _saveItems();
              },
              itemBuilder: (context, index) {
                final item = _items[index];
                return ChecklistItemTile(
                  key: Key(item.id),
                  item: item,
                  index: index,
                  onDelete: () {
                    setState(() {
                      _items.removeAt(index);
                    });
                    _saveItems();
                  },
                  onToggle: (value) => _toggleItem(index, value),
                  onEdit: () => _editItemText(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
