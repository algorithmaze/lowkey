
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:lowkey/contacts/user.dart';

class UserRepository {
  final SupabaseClient _supabaseClient;

  UserRepository(this._supabaseClient);

  Future<void> createUserProfile({required String userId, required String username}) async {
    try {
      await _supabaseClient.from('profiles').insert({
        'id': userId,
        'username': username,
        'is_online': true,
        'last_seen': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getUserProfile(String userId) async {
    final response = await _supabaseClient.from('profiles').select().eq('id', userId).maybeSingle();
    if (response != null) {
      return User.fromJson(response);
    }
    return null;
  }

  Future<User?> getUserProfileById(String userId) async {
    final response = await _supabaseClient.from('profiles').select().eq('id', userId).single();
    if (response.isNotEmpty) {
      return User.fromJson(response);
    }
    return null;
  }

  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await _supabaseClient.from('profiles').update({
      'is_online': isOnline,
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  Stream<List<User>> getOnlineUsers() {
    return _supabaseClient
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('is_online', true)
        .map((maps) => maps.map((map) => User.fromJson(map)).toList());
  }

  Stream<List<User>> getAllProfilesStream() {
    return _supabaseClient
        .from('profiles')
        .stream(primaryKey: ['id'])
        .map((maps) => maps.map((map) => User.fromJson(map)).toList());
  }
}
