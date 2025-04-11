import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart'; // Import your Todo model

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new Todo
  Future<void> addTodo(Todo todo) async {
    await _firestore.collection('todos').doc(todo.id).set({
      'title': todo.title,
      'category': todo.category,
    });
  }

  Future<void> removeTodo(String todoId) async {
    await _firestore.collection('todos').doc(todoId).delete();
  }

  Future<void> updateTodo(Todo todo) async {
    await _firestore.collection('todos').doc(todo.id).update({
      'title': todo.title,
      'category': todo.category,
    });
  }

    // Get all Todos
    Stream<List<Todo>> getTodos() {
      return _firestore.collection('todos').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Todo(
            id: doc.id,
            title: doc['title'],
            category: doc['category'], content: '',
          );
        }).toList();
      });
    }
  }
