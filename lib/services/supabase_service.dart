import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/auth_service.dart';
import '../dashboard/task_model.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;
  final AuthService _authService;

  SupabaseService(this._authService);

  /// Get all tasks for the current user
  Future<List<Task>> getTasks() async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('tasks')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((data) => Task.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  /// Add a new task
  Future<Task> addTask(Task task) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final Map<String, dynamic> taskData = {
      'title': task.title,
      'is_completed': task.isCompleted,
      'user_id': user.id,
    };

    final response =
        await _supabase.from('tasks').insert(taskData).select().single();

    return Task.fromJson(response);
  }

  /// Update a task
  Future<void> updateTask(Task task) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final Map<String, dynamic> taskData = {
      'title': task.title,
      'is_completed': task.isCompleted,
    };

    await _supabase
        .from('tasks')
        .update(taskData)
        .eq('id', task.id)
        .eq('user_id', user.id);
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _supabase
        .from('tasks')
        .delete()
        .eq('id', taskId)
        .eq('user_id', user.id);
  }
}
