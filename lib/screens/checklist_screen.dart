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
  final TextEditingController _saveListNameController = TextEditingController();
  bool _isAddingItem = false;
  String? _currentListName;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    _saveListNameController.dispose();
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

  void _toggleAddItem() {
    setState(() {
      _isAddingItem = !_isAddingItem;
      if (!_isAddingItem) {
        _controller.clear();
      }
    });
  }

  Future<void> _openSavedListsDialog() async {
    _saveListNameController.clear();
    var savedListNames = await widget._repository.loadSavedListNames();

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Saved lists'),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _saveListNameController,
                      decoration: const InputDecoration(
                        labelText: 'New list name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () async {
                        final name = _saveListNameController.text.trim();
                        if (name.isEmpty) {
                          return;
                        }

                        await widget._repository.saveNamedList(name, _items);
                        final updatedNames =
                            await widget._repository.loadSavedListNames();

                        if (!mounted) {
                          return;
                        }

                        setState(() {
                          _currentListName = name;
                        });

                        if (!dialogContext.mounted) {
                          return;
                        }

                        setDialogState(() {
                          savedListNames = updatedNames;
                        });
                        _saveListNameController.clear();
                      },
                      child: const Text('Save'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Existing files',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (savedListNames.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No saved lists yet.'),
                      )
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: savedListNames.length,
                          itemBuilder: (context, index) {
                            final name = savedListNames[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(name),
                              onTap: () async {
                                final loadedItems =
                                    await widget._repository.loadNamedList(name);

                                if (!mounted) {
                                  return;
                                }

                                setState(() {
                                  _items
                                    ..clear()
                                    ..addAll(loadedItems);
                                  _currentListName = name;
                                  _isAddingItem = false;
                                  _controller.clear();
                                });
                                await _saveItems();

                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            _currentListName == null
                ? 'Checklist'
                : 'Checklist - $_currentListName',
            softWrap: false,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _openSavedListsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _toggleAddItem,
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isAddingItem)
            ChecklistInputBar(
              controller: _controller,
              onAdd: _addItem,
            ),
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: true,
              itemCount: _items.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
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
