import 'package:supabase_flutter/supabase_flutter.dart';
import '../lib/models/todo_model.dart';

class TodoService {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchTodosRaw() async {
    final response = await supabase
        .from('todos')
        .select()
        .order('created_at', ascending: false);

    return response as List<dynamic>;
  }
}
