import 'dart:convert';

class Task {
  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final bool isCompleted;

  Task copyWith({String? id, String? title, bool? isCompleted}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  static String encodeList(List<Task> tasks) =>
      jsonEncode(tasks.map((Task t) => t.toJson()).toList());

  static List<Task> decodeList(String source) {
    final List<dynamic> list = jsonDecode(source) as List<dynamic>;
    return list.map((dynamic e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }
}


