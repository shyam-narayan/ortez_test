import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/todo.dart';

class TodoApiService {
  static const String baseUrl = 'https://dummyjson.com/todos';
  // static bool useDummyData = false;
  Future<List<Todo>> fetchTodos() async {
    // if (useDummyData) {
    //   return await _fetchTodosFromDummyData();
    // }
    final response = await http.get(
      Uri.parse(baseUrl),
      // headers: {'User-Agent': 'Mozilla/5.0'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['todos'];
      return data.map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  // Future<List<Todo>> _fetchTodosFromDummyData() async {
  //   try {
  //     final jsonString = await rootBundle.loadString(
  //       'lib/dummy_data/dummy_data.json',
  //     );
  //     final List<dynamic> data = json.decode(jsonString);
  //     return data.map((json) => Todo.fromJson(json)).toList();
  //   } catch (e) {
  //     return [];
  //   }
  // }

  Future<Todo> fetchTodoById(int id) async {
    // if (useDummyData) {
    //   final todos = await _fetchTodosFromDummyData();
    //   return todos.firstWhere((t) => t.id == id);
    // }
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Todo.fromJson(data);
    } else {
      throw Exception('Failed to load todo');
    }
  }

  Future<List<Todo>> fetchTodosByUserId(int userId) async {
    final url = 'https://dummyjson.com/todos/user/$userId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['todos'];
      return data.map((json) => Todo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load todos for user $userId');
    }
  }

  // Mocked: does not persist
  Future<Todo> updateTodo(Todo todo) async {
    await Future.delayed(Duration(milliseconds: 500));
    return todo;
  }

  Future<Todo> addTodoToApi(Todo todo) async {
    final url = Uri.parse('https://dummyjson.com/todos/add');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'todo': todo.todo,
        'completed': todo.completed,
        'userId': todo.userId,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      log("added todo: ${data.toString()}");
      return Todo.fromJson(data);
    } else {
      throw Exception('Failed to add todo: \\${response.statusCode}');
    }
  }

  Future<Todo> updateTodoInApi(Todo todo) async {
    final url = Uri.parse('https://dummyjson.com/todos/${todo.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'todo': todo.todo,
        'completed': todo.completed,
        'userId': todo.userId,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('Updated todo: \\n\\${data.toString()}');
      return Todo.fromJson(data);
    } else {
      throw Exception('Failed to update todo: \\${response.statusCode}');
    }
  }
}
