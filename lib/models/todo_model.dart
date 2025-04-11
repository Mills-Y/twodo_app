import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String id;
  final String title;
  final String category;
  final String content;

  // Constructor
  const Todo({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
  };

  // Convert from JSON
  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    category: json['category'],
  );

  @override
  List<Object?> get props => [id, title, content, category];

}