import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/todos.json');
  }

  Future<List<dynamic>> readTodos() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return json.decode(contents);
    } catch (e) {
      return []; // Return an empty list on error
    }
  }

  Future<File> writeTodos(List<dynamic> todos) async {
    final file = await _localFile;
    return file.writeAsString(json.encode(todos));
  }
}