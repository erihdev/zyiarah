import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: ضع رابط وتوكن مشروعك في Supabase هنا
  // تم إنشاء المشروع وتوليد المفاتيح آلياً
  static const String supabaseUrl = 'https://rlvqklkhorkfhyprlswk.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJsdnFrbGtob3JrZmh5cHJsc3drIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIwNjMyNDgsImV4cCI6MjA4NzYzOTI0OH0.wRU9cOnLz7HmAaWV6yPRR5DQ6RWenSaJztkshmXg6jo';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
