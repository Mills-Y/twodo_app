import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';
import '../models/todo_model.dart';

class Toodo extends Equatable {
  final String id;
  final String title;
  final String category;
  final String content;

  const Toodo({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
  });



  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
  };

  factory Toodo.fromJson(Map<String, dynamic> json) => Toodo(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    category: json['category'],
  );

  @override
  List<Object?> get props => [id, title, content, category];
}

// --- Events ---
abstract class ToodoEvent extends Equatable {
  const ToodoEvent();
  @override
  List<Object?> get props => [];
}

class ToodoAdded extends ToodoEvent {
  final Toodo todo;
  const ToodoAdded(this.todo);
  @override
  List<Object?> get props => [todo];
}

class ToodoDeleted extends ToodoEvent {
  final String todoId;
  const ToodoDeleted(this.todoId);
  @override
  List<Object?> get props => [todoId];
}

class ToodoRequested extends ToodoEvent {}

class CategoryChanged extends ToodoEvent {
  final String category;
  const CategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}

// --- States ---
abstract class ToodoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ToodoInitial extends ToodoState {}

class ToodoLoading extends ToodoState {}

class ToodoLoaded extends ToodoState {
  final List<Toodo> workTodos;
  final List<Toodo> personalTodos;
  final String selectedCategory;

  ToodoLoaded(this.workTodos, this.personalTodos, this.selectedCategory);

  @override
  List<Object?> get props => [workTodos, personalTodos, selectedCategory];
}

class ToodoError extends ToodoState {
  final String message;
  ToodoError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Bloc --
class TodoBloc extends Bloc<ToodoEvent, ToodoState> {
  List<Toodo> _todos = [];
  String selectedCategory = 'All';
  static const String _todosKey = 'todos';
  final SharedPreferences _prefs;

  TodoBloc(this._prefs) : super(ToodoInitial()) {
    on<ToodoAdded>(_onTodoAdded);
    on<ToodoDeleted>(_onTodoDeleted);
    on<ToodoRequested>(_onTodoRequested);
    on<CategoryChanged>(_onCategoryChanged);

    // Load todos when the block is initialized
    add(ToodoRequested());
  }

  Future<void> _onTodoRequested(
      ToodoRequested event, Emitter<ToodoState> emit) async {
    emit(ToodoLoading());
    try {
      await _loadTodos();
      emit(_filterTodosByCategory());
    } catch (e) {
      emit(ToodoError('Failed to load todos: $e'));
    }
  }

  Future<void> _onTodoAdded(ToodoAdded event, Emitter<ToodoState> emit) async {
    _todos.add(event.todo);
    await _saveTodos();
    emit(_filterTodosByCategory());
  }

  Future<void> _onTodoDeleted(ToodoDeleted event, Emitter<ToodoState> emit) async {
    _todos.removeWhere((todo) => todo.id == event.todoId);
    await _saveTodos();
    emit(_filterTodosByCategory());
  }

  Future<void> _onCategoryChanged(CategoryChanged event, Emitter<ToodoState> emit) async {
    selectedCategory = event.category;
    emit(_filterTodosByCategory());
  }

  Future<void> _loadTodos() async {
    final todosJson = _prefs.getString(_todosKey);
    if (todosJson != null) {
      final List<dynamic> decodedList = json.decode(todosJson);
      _todos = decodedList.map((json) => Toodo.fromJson(json)).toList();
    } else {
      _todos = [];
    }
  }

  Future<void> _saveTodos() async {
    final todosJson = json.encode(_todos.map((todo) => todo.toJson()).toList());
    await _prefs.setString(_todosKey, todosJson);
  }

  ToodoLoaded _filterTodosByCategory() {
    List<Toodo> filteredWorkTodos = [];
    List<Toodo> filteredPersonalTodos = [];

    for (Toodo todo in _todos) {
      if (todo.category == 'Work') {
        filteredWorkTodos.add(todo);
      } else if (todo.category == 'Personal') {
        filteredPersonalTodos.add(todo);
      }
    }
    // Return filtered todos based on the selected category
    if (selectedCategory == 'Work') {
      return ToodoLoaded(filteredWorkTodos.cast<Toodo>(), [], selectedCategory);
    } else if (selectedCategory == 'Personal') {
      return ToodoLoaded([], filteredPersonalTodos.cast<Toodo>(), selectedCategory);
    } else {
      return ToodoLoaded(filteredWorkTodos.cast<Toodo>(), filteredPersonalTodos.cast<Toodo>(), selectedCategory);
    }
  }
}