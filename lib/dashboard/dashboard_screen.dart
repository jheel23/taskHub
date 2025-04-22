import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../auth/auth_service.dart';
import '../services/supabase_service.dart';
import 'task_model.dart';
import 'task_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    try {
      final supabaseService = Provider.of<SupabaseService>(
        context,
        listen: false,
      );
      final tasks = await supabaseService.getTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
        _errorMessage = null;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading tasks: ${e.toString()}';
      });
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      final supabaseService = Provider.of<SupabaseService>(
        context,
        listen: false,
      );
      await supabaseService.deleteTask(task.id);

      setState(() {
        _tasks.removeWhere((t) => t.id == task.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Task deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleTaskStatus(Task task) async {
    try {
      final supabaseService = Provider.of<SupabaseService>(
        context,
        listen: false,
      );
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await supabaseService.updateTask(updatedTask);

      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: ${e.toString()}')),
        );
      }
    }
  }

  void _showAddTaskDialog() {
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Task',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'Task title',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (textController.text.trim().isNotEmpty) {
                        final task = Task(
                          id: '', // Will be set by Supabase
                          title: textController.text.trim(),
                          isCompleted: false,
                          createdAt: DateTime.now(),
                        );

                        try {
                          final supabaseService = Provider.of<SupabaseService>(
                            context,
                            listen: false,
                          );
                          final newTask = await supabaseService.addTask(task);

                          setState(() {
                            _tasks.add(newTask);
                          });

                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error adding task: ${e.toString()}',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text('Add Task'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              await authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppTheme.errorColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTasks,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _tasks.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 80,
                      color: AppTheme.greyTextColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tasks yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.greyTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add your first task',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.greyTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showAddTaskDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Task'),
                    ),
                  ],
                ),
              )
              : FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return TaskTile(
                        task: task,
                        onDelete: () => _deleteTask(task),
                        onToggle: () => _toggleTaskStatus(task),
                      );
                    },
                  ),
                ),
              ),
      floatingActionButton:
          _tasks.isNotEmpty
              ? FloatingActionButton(
                onPressed: _showAddTaskDialog,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
