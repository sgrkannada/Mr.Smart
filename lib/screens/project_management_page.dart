import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // For date formatting

// Theme constants (copied for consistency)
const Color neonCyan = Color(0xFF00E5FF);
const Color darkBackground = Color(0xFF121212);
const Color cardColor = Color(0xFF1F1F1F);

// Data Models
class Task {
  final String id;
  String name;
  DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.name,
    this.dueDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dueDate': dueDate?.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        name: json['name'],
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        isCompleted: json['isCompleted'],
      );
}

class Project {
  final String id;
  String name;
  List<Task> tasks;
  Color color; // Neon color for the card

  Project({
    required this.id,
    required this.name,
    required this.tasks,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tasks': tasks.map((task) => task.toJson()).toList(),
        'color': color.value,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'],
        name: json['name'],
        tasks: (json['tasks'] as List).map((taskJson) => Task.fromJson(taskJson)).toList(),
        color: Color(json['color']),
      );
}

class ProjectManagementPage extends StatefulWidget {
  const ProjectManagementPage({super.key});

  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  List<Project> _projects = [];
  final Uuid _uuid = const Uuid();
  final List<Color> _neonColors = [
    neonCyan,
    const Color(0xFF39FF14), // Neon Green
    const Color(0xFFFF073A), // Neon Red/Pink
    const Color(0xFFFEF44C), // Neon Yellow
    const Color(0xFF00FFFF), // Neon Aqua
    const Color(0xFFEE82EE), // Violet
    const Color(0xFF00FF00), // Lime
    const Color(0xFFFFD700), // Gold
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final String? projectsString = prefs.getString('projects');
    if (projectsString != null) {
      final List<dynamic> jsonList = jsonDecode(projectsString);
      setState(() {
        _projects = jsonList.map((json) => Project.fromJson(json)).toList();
      });
    }
  }

  Future<void> _saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final String projectsString = jsonEncode(_projects.map((project) => project.toJson()).toList());
    await prefs.setString('projects', projectsString);
  }

  Future<void> _addProject() async {
    final TextEditingController nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Project'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Project Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newProject = Project(
                  id: _uuid.v4(),
                  name: nameController.text,
                  tasks: [],
                  color: _neonColors[_projects.length % _neonColors.length],
                );
                setState(() {
                  _projects.add(newProject);
                });
                _saveProjects();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTask(Project project) async {
    final TextEditingController nameController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Task Name'),
            ),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setState) {
                return TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(
                    selectedDate == null
                        ? 'Select Due Date'
                        : 'Due: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                    style: TextStyle(color: neonCyan),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newTask = Task(
                  id: _uuid.v4(),
                  name: nameController.text,
                  dueDate: selectedDate,
                );
                setState(() {
                  project.tasks.add(newTask);
                });
                _saveProjects();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _toggleTaskCompletion(Project project, Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    _saveProjects();
  }

  void _deleteProject(String projectId) {
    setState(() {
      _projects.removeWhere((project) => project.id == projectId);
    });
    _saveProjects();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Project deleted.')),
    );
  }

  void _deleteTask(Project project, String taskId) {
    setState(() {
      project.tasks.removeWhere((task) => task.id == taskId);
    });
    _saveProjects();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted.')),
    );
  }

  Future<void> _editProjectName(Project project) async {
    final TextEditingController nameController = TextEditingController(text: project.name);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Project Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Project Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  project.name = nameController.text;
                });
                _saveProjects();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _editTask(Project project, Task task) async {
    final TextEditingController nameController = TextEditingController(text: task.name);
    DateTime? selectedDate = task.dueDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Task Name'),
            ),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setState) {
                return TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text(
                    selectedDate == null
                        ? 'Select Due Date'
                        : 'Due: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                    style: TextStyle(color: neonCyan),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  task.name = nameController.text;
                  task.dueDate = selectedDate;
                });
                _saveProjects();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Manager'),
        backgroundColor: darkBackground,
        elevation: 0,
      ),
      backgroundColor: darkBackground,
      body: _projects.isEmpty
          ? const Center(
              child: Text(
                'No projects yet. Add one to get started!',
                style: TextStyle(color: Colors.white70, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                final project = _projects[index];
                return _buildProjectCard(project);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProject,
        label: const Text('Add Project'),
        icon: const Icon(Icons.add),
        backgroundColor: neonCyan,
        foregroundColor: darkBackground,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildProjectCard(Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: project.color.withOpacity(0.6), width: 1.5),
      ),
      elevation: 5,
      shadowColor: project.color.withOpacity(0.3),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          project.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: project.color, blurRadius: 5)],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: project.color),
              onPressed: () => _editProjectName(project),
              tooltip: 'Edit Project Name',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _deleteProject(project.id),
              tooltip: 'Delete Project',
            ),
            Icon(Icons.expand_more, color: neonCyan),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (project.tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'No tasks yet. Add one!',
                      style: TextStyle(color: Colors.white70.withOpacity(0.8)),
                    ),
                  ),
                ...project.tasks.map((task) => _buildTaskListItem(project, task)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _addTask(project),
                    icon: Icon(Icons.add_task, color: neonCyan),
                    label: Text('Add Task', style: TextStyle(color: neonCyan)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListItem(Project project, Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: (bool? value) => _toggleTaskCompletion(project, task),
            activeColor: neonCyan,
            checkColor: darkBackground,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.white54 : Colors.white,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    fontSize: 16,
                  ),
                ),
                if (task.dueDate != null)
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate!)}',
                    style: TextStyle(
                      color: Colors.white70.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: project.color.withOpacity(0.7)),
            onPressed: () => _editTask(project, task),
            tooltip: 'Edit Task',
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _deleteTask(project, task.id),
            tooltip: 'Delete Task',
          ),
        ],
      ),
    );
  }
}