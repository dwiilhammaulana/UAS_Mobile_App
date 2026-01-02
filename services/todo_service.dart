import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todo_model.dart';

class TodoService {
  final supabase = Supabase.instance.client;

  Future<List<Todo>> fetchTodos() async {
    final response = await supabase
        .from('todos')
        .select()
        .order('created_at', ascending: false);

    final data = response as List;
    return data.map((e) => Todo.fromJson(e)).toList();
  }
}
