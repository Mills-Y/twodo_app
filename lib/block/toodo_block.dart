import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';
import '../models/todo_model.dart';



// --- Events ---
abstract class ToodoEvent extends Equatable {
  const ToodoEvent();
  @override
  List<Object?> get props => [];
}

class ToodoAdded extends ToodoEvent {
  final Todo todo;
  const ToodoAdded(this.todo);
  @override
  List<Object?> get props => [todo];
}

class EditToodo extends ToodoEvent {
  final Todo todo;
  const EditToodo(this.todo);
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
  final List<Todo> workTodos;
  final List<Todo> personalTodos;
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

// --- Bloc ---
class TodoBloc extends Bloc<ToodoEvent, ToodoState> {
  List<Todo> _todos = [];
  String selectedCategory = 'All';
  static const String _todosKey = 'todos';
  final SharedPreferences _prefs;

  TodoBloc(this._prefs) : super(ToodoInitial()) {
    on<ToodoAdded>(_onTodoAdded);
    on<ToodoDeleted>(_onTodoDeleted);
    on<ToodoRequested>(_onTodoRequested);
    on<CategoryChanged>(_onCategoryChanged);
    on<EditToodo>(_onEditTodo);
    add(ToodoRequested()); // Load todos when the bloc is initialized
  }

  Future<void> _onTodoRequested(ToodoRequested event, Emitter<ToodoState> emit) async {
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

  Future<void> _onEditTodo(EditToodo event, Emitter<ToodoState> emit) async {
    final index = _todos.indexWhere((todo) => todo.id == event.todo.id);
    if (index != -1) {
      _todos[index] = event.todo;
      await _saveTodos();
      emit(_filterTodosByCategory());
    } else {
      print('Todo with id ${event.todo.id} not found.');
    }
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
      _todos = decodedList.map((json) => Todo.fromJson(json)).toList();
    } else {
      _todos = [];
    }
  }

  Future<void> _saveTodos() async {
    final todosJson = json.encode(_todos.map((todo) => todo.toJson()).toList());
    await _prefs.setString(_todosKey, todosJson);
  }

  ToodoLoaded _filterTodosByCategory() {
    List<Todo> filteredWorkTodos = [];
    List<Todo> filteredPersonalTodos = [];

    for (Todo todo in _todos) {
      if (todo.category == 'Work') {
        filteredWorkTodos.add(todo);
      } else if (todo.category == 'Personal') {
        filteredPersonalTodos.add(todo);
      }
    }
    if (selectedCategory == 'Work') {
      return ToodoLoaded(filteredWorkTodos, [], selectedCategory);
    } else if (selectedCategory == 'Personal') {
      return ToodoLoaded([], filteredPersonalTodos, selectedCategory);
    } else {
      return ToodoLoaded(filteredWorkTodos, filteredPersonalTodos, selectedCategory);
    }
  }
}