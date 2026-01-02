import 'package:supabase_flutter/supabase_flutter.dart';
import '../lib/models/todo_model.dart';

class TodoService {
  final supabase = Supabase.instance.client;
}
