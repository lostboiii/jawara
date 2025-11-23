import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://fbyriwzdgdihwqxvbzmy.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZieXJpd3pkZ2RpaHdxeHZiem15Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NDk2MTgsImV4cCI6MjA3ODMyNTYxOH0.ZcTM8gFTsCfKMm1qDlo5aHRphtuH6Y9UhFWBHu2nuvA',
    );
  }
}
