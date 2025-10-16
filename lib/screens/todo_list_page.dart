import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:smart_bro/utils/points_manager.dart'; // Import PointsManager

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

class TodoItem {
  String id;
  String task;
  bool isCompleted;

  TodoItem({required this.id, required this.task, this.isCompleted = false});

  Map<String, dynamic> toJson() => {
        'id': id,
        'task': task,
        'isCompleted': isCompleted,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'],
        task: json['task'],
        isCompleted: json['isCompleted'],
      );
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController _taskController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<TodoItem> _todoList = [];

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _loadTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todoListString = prefs.getString('todo_list');
    if (todoListString != null) {
      final List<dynamic> jsonList = json.decode(todoListString);
      setState(() {
        _todoList = jsonList.map((json) => TodoItem.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final String todoListString = json.encode(_todoList.map((item) => item.toJson()).toList());
    await prefs.setString('todo_list', todoListString);
  }

  void _addTask() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _todoList.add(TodoItem(id: DateTime.now().toIso8601String(), task: _taskController.text));
        _taskController.clear();
      });
      _saveTodoList();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added!')),
      );
    }
  }

  void _toggleTaskCompletion(TodoItem item) async {
    setState(() {
      item.isCompleted = !item.isCompleted;
    });
    _saveTodoList();
    if (item.isCompleted) {
      await PointsManager.awardPoints(5);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task completed! +5 points!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task marked incomplete!')),
      );
    }
  }

  void _deleteTask(TodoItem item) {
    setState(() {
      _todoList.removeWhere((todo) => todo.id == item.id);
    });
    _saveTodoList();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted!')),
    );
  }

  void _clearCompletedTasks() {
    setState(() {
      _todoList.removeWhere((item) => item.isCompleted);
    });
    _saveTodoList();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Completed tasks cleared!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        backgroundColor: darkBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: neonCyan),
            onPressed: _clearCompletedTasks,
            tooltip: 'Clear Completed Tasks',
          ),
        ],
      ),
      backgroundColor: darkBackground,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _taskController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Add a new task',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: neonCyan),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: neonCyan, width: 2),
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Task cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: _addTask,
                    backgroundColor: neonCyan,
                    mini: true,
                    child: const Icon(Icons.add, color: darkBackground),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _todoList.isEmpty
                ? Center(
                    child: Text(
                      'No tasks yet! Add one above.',
                      style: TextStyle(color: Colors.white70.withAlpha((255 * 0.8).round()), fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _todoList.length,
                    itemBuilder: (context, index) {
                      final item = _todoList[index];
                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(
                            item.task,
                            style: TextStyle(
                              color: item.isCompleted ? Colors.grey : Colors.white,
                              decoration: item.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          leading: Checkbox(
                            value: item.isCompleted,
                            onChanged: (bool? value) {
                              _toggleTaskCompletion(item);
                            },
                            activeColor: neonCyan,
                            checkColor: darkBackground,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteTask(item),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}