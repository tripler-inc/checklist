import 'package:checklist/models/checklist_item.dart';
import 'package:flutter/material.dart';

class ChecklistItemTile extends StatelessWidget {
  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.index,
    required this.onDelete,
    required this.onToggle,
    required this.onEdit,
  });

  final ChecklistItem item;
  final int index;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('dismiss_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: CheckboxListTile(
        title: GestureDetector(
          onTap: onEdit,
          child: Text(
            item.text,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        value: item.checked,
        onChanged: onToggle,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
