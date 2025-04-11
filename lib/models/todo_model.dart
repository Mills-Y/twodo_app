import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String title;
  final String category;
  final String content;
  final DateTime? dueDate;

  // Constructor
  const Todo({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.dueDate,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
    'dueDate': dueDate?.toIso8601String(),
  };

  // Convert from JSON
  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    category: json['category'],
    dueDate: json['dueDate'] != null
        ? DateTime.parse(json['dueDate'])
        : null,
  );

  @override
  List<Object?> get props => [id, title, content, category, dueDate];

}