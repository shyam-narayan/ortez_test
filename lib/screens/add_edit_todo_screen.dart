import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/todo.dart';
import '../controller/todo_controller.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo? todo;
  const AddEditTodoScreen({Key? key, this.todo}) : super(key: key);

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  bool _completed = false;
  final TextEditingController _userIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _title = widget.todo?.todo ?? '';
    _completed = widget.todo?.completed ?? false;
    if (widget.todo == null) {
      _userIdController.text = '';
    }
  }

  void _save() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final controller = Get.find<TodoController>();
      if (widget.todo == null) {
        final userId = int.tryParse(_userIdController.text.trim());
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid user ID.')),
          );
          return;
        }
        final newTodo = Todo(
          userId: userId,
          id: DateTime.now().millisecondsSinceEpoch,
          todo: _title,
          completed: _completed,
        );
        await controller.addTodo(newTodo);
        log('Added todo: \nUserId: \\${newTodo.userId}, Title: \\${newTodo.todo}, Completed: \\${newTodo.completed}');
      } else {
        final updatedTodo = Todo(
          userId: widget.todo!.userId,
          id: widget.todo!.id,
          todo: _title,
          completed: _completed,
        );
        await controller.updateTodo(updatedTodo);
        log('Updated todo: \nId: \\${updatedTodo.id}, UserId: \\${updatedTodo.userId}, Title: \\${updatedTodo.todo}, Completed: \\${updatedTodo.completed}');
      }
      Get.back();
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.todo == null ? 'Add Todo.' : 'Edit Todo.',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontFamily: GoogleFonts.dmSerifDisplay().fontFamily,
            fontWeight: FontWeight.w800,
            fontSize: 32,
            height: 1.1,
          ),
        ),
        toolbarHeight: 100,
        centerTitle: false,
        elevation: 0,
        titleSpacing: 24,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.todo == null) ...[
                TextFormField(
                  controller: _userIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'User ID'),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'User ID is required';
                    }
                    if (int.tryParse(val.trim()) == null) {
                      return 'User ID must be a number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
              ],
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Title is required' : null,
                onSaved: (val) => _title = val ?? '',
              ),
              SizedBox(height: 10),
              CheckboxListTile(
                value: _completed,
                onChanged: (val) => setState(() => _completed = val ?? false),
                title: const Text('Completed'),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _save,
                child: Container(
                  height: MediaQuery.of(context).size.width * 0.1,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
