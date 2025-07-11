import 'dart:developer';

import 'package:get/get.dart';
import '../models/todo.dart';
import '../services/todo_api_service.dart';
import 'package:hive/hive.dart';

class TodoController extends GetxController {
  final TodoApiService _apiService = TodoApiService();
  var todos = <Todo>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() async {
    await Hive.openBox<Todo>('todos');
    fetchTodos();
    super.onInit();
  }

  Future<void> fetchTodos() async {
    isLoading.value = true;
    final box = Hive.box<Todo>('todos');
    try {
      final fetched = await _apiService.fetchTodos();
      todos.assignAll(fetched);
      // Save to Hive
      await box.clear();
      await box.addAll(fetched);
    } catch (e) {
      // Load from Hive if available
      final localTodos = box.values.toList();
      if (localTodos.isNotEmpty) {
        todos.assignAll(localTodos);
      } else {
        todos.clear();
      }
    }
    isLoading.value = false;
  }

  Future<void> addTodo(Todo todo) async {
    try {
      final newTodo = await _apiService.addTodoToApi(todo);
      todos.insert(0, newTodo);
      // Save to Hive
      final box = Hive.box<Todo>('todos');
      await box.clear();
      await box.addAll(todos);
    } catch (e) {
      // Optionally handle error (e.g., show snackbar)
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      final updated = await _apiService.updateTodoInApi(todo);
      final index = todos.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
        todos[index] = updated;
        todos.refresh();
        // Save to Hive
        final box = Hive.box<Todo>('todos');
        await box.clear();
        await box.addAll(todos);
      }
    } catch (e) {
      // Optionally handle error (e.g., show snackbar)
    }
  }

  Future<void> fetchTodosForUser(int userId) async {
    isLoading.value = true;
    final box = Hive.box<Todo>('todos');
    try {
      final fetched = await _apiService.fetchTodosByUserId(userId);
      todos.assignAll(fetched);
      // Optionally, save to Hive if you want to cache per-user
      await box.clear();
      await box.addAll(fetched);
    } catch (e) {
      // Load from Hive if available
      final localTodos = box.values.toList();
      if (localTodos.isNotEmpty) {
        todos.assignAll(localTodos);
      } else {
        todos.clear();
      }
    }
    isLoading.value = false;
  }

  Todo? getTodoById(int id) {
    return todos.firstWhereOrNull((t) => t.id == id);
  }
}
