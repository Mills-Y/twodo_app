import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo_model.dart';

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  /// Fetches the list of todos from the API.
  Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/todos'));

    // Log the response for debugging
    print('Fetching todos from: $baseUrl/todos');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Todo.fromJson(json)).toList(); // Convert to List<Toodo>
    } else {
      // Handle non-200 responses
      throw Exception('Failed to load todos: ${response.statusCode} - ${response.body}');
    }
  }

  /// Adds a new todo to the API.
  Future<void> addTodo(Todo todo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(todo.toJson()), // Use toJson() method
    );

    // Log the response for debugging
    print('Adding todo to: $baseUrl/todos');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Failed to add todo: ${response.statusCode} - ${response.body}');
    }
  }

  /// Updates an existing todo in the API.
  Future<void> updateTodo(Todo todo) async {
    final response = await http.put(
      Uri.parse('$baseUrl/todos/${todo.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(todo.toJson()), // Use toJson() method
    );

    // Log the response for debugging
    print('Updating todo at: $baseUrl/todos/${todo.id}');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update todo: ${response.statusCode} - ${response.body}');
    }
  }

  /// Deletes a todo from the API.
  Future<void> deleteTodo(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/todos/$id'));

    // Log the response for debugging
    print('Deleting todo at: $baseUrl/todos/$id');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete todo: ${response.statusCode} - ${response.body}');
    }
  }
}