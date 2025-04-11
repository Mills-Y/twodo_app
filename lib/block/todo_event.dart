import '../models/todo_model.dart';

abstract class TodoEvent {}

class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final String todo;
  final String category;// New field for category

  AddTodo(this.todo, this.category);
}

class EditTodo extends TodoEvent {
  final Todo todo;

  EditTodo(this.todo);
}

class RemoveTodo extends TodoEvent {
  final String todoId;

  RemoveTodo(this.todoId);
}