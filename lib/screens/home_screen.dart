// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/todo_controller.dart';
import '../models/todo.dart';
import 'add_edit_todo_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TodoController controller = Get.find();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  bool _showSearchBar = false;
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchBarAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
      if (_showSearchBar) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
        _searchQuery = '';
        FocusScope.of(context).unfocus();
      }
    });
  }

  List<Todo> _getFilteredTodos() {
    if (_searchQuery.isEmpty) return controller.todos;
    return controller.todos
        .where(
          (todo) =>
              todo.todo.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ToDo.',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontFamily: GoogleFonts.dmSerifDisplay().fontFamily,
            fontWeight: FontWeight.w800,
            fontSize: 32,
            height: 1.1,
          ),
        ),
        toolbarHeight: 100,
        actions: [
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search, size: 28),
            onPressed: _toggleSearchBar,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 24),
            tooltip: 'App Info',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const InfoScreen()));
            },
          ),
        ],
        centerTitle: false,
        elevation: 0,
        titleSpacing: 24,
      ),
      body: Column(
        children: [
          Container(height: 1, color: Colors.white),
          SizeTransition(
            sizeFactor: _searchBarAnimation,
            axisAlignment: -1.0,
            child: Column(
              children: [
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontFamily: GoogleFonts.overpassMono().fontFamily,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search todos...',
                      hintStyle: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFAAAAAA),
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: accent, size: 24),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 18,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF181818),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _userIdController,
                          keyboardType: TextInputType.number,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontFamily: GoogleFonts.overpassMono().fontFamily,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by user ID...',
                            hintStyle: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFAAAAAA),
                            ),

                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.person,
                              color: accent,
                              size: 24,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 18,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF181818),
                          ),
                          onChanged: (value) async {
                            if (value.isEmpty) {
                              controller.fetchTodos();
                              return;
                            }

                            final userId = int.tryParse(value);
                            if (userId != null) {
                              final connectivityResult = await Connectivity()
                                  .checkConnectivity();
                              if (connectivityResult ==
                                  ConnectivityResult.none) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'No internet connection. Please try again when online.',
                                    ),
                                  ),
                                );
                              } else {
                                controller.fetchTodosForUser(userId);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User ID must be a number.'),
                                ),
                              );
                            }
                          },
                          onSubmitted: (value) async {
                            if (value.isEmpty) {
                              controller.fetchTodos();
                              return;
                            }

                            final userId = int.tryParse(value);
                            if (userId != null) {
                              final connectivityResult = await Connectivity()
                                  .checkConnectivity();
                              if (connectivityResult ==
                                  ConnectivityResult.none) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'No internet connection. Please try again when online.',
                                    ),
                                  ),
                                );
                              } else {
                                controller.fetchTodosForUser(userId);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User ID must be a number.'),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward, color: accent),
                        onPressed: () async {
                          final text = _userIdController.text.trim();
                          if (text.isEmpty) {
                            controller.fetchTodos();
                          } else {
                            final userId = int.tryParse(text);
                            if (userId != null) {
                              final connectivityResult = await Connectivity()
                                  .checkConnectivity();
                              if (connectivityResult ==
                                  ConnectivityResult.none) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'No internet connection. Please try again when online.',
                                    ),
                                  ),
                                );
                              } else {
                                controller.fetchTodosForUser(userId);
                              }
                            } else {}
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.white),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final filteredTodos = _getFilteredTodos();
              if (filteredTodos.isEmpty) {
                return Center(
                  child: Text(
                    'No todos found.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFFAAAAAA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return ScrollbarTheme(
                data: ScrollbarThemeData(),
                child: Scrollbar(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    itemCount: filteredTodos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final todo = filteredTodos[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF181818),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF232323)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(
                            left: 16,
                            top: 8,
                            right: 8,
                            bottom: 8,
                          ),
                          title: Text(
                            todo.todo,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontFamily: GoogleFonts.overpassMono().fontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          leading: Checkbox(
                            value: todo.completed,
                            onChanged: (val) {
                              final updatedTodo = Todo(
                                userId: todo.userId,
                                id: todo.id,
                                todo: todo.todo,
                                completed: val ?? false,
                              );
                              controller.updateTodo(updatedTodo);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            side: BorderSide(color: accent, width: 2),
                            activeColor: accent,
                            checkColor: Colors.black,
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              Get.to(() => AddEditTodoScreen(todo: todo));
                            },
                            icon: Icon(CupertinoIcons.chevron_forward),
                          ),
                          onTap: () {
                            Get.to(() => AddEditTodoScreen(todo: todo));
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddEditTodoScreen());
        },
        elevation: 0,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}
