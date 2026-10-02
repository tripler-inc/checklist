class ChecklistItem {
  ChecklistItem(
    this.text, {
    this.checked = false,
    String? id,
  }) : id = id ?? _generateId();

  final String id;
  String text;
  bool checked;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'checked': checked,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      json['text'] as String? ?? '',
      checked: json['checked'] as bool? ?? false,
      id: json['id'] as String?,
    );
  }

  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
