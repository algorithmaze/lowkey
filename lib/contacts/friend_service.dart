import 'package:lowkey/contacts/friend_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:lowkey/contacts/user.dart'; // Assuming you have a User model

import 'package:lowkey/chat/chat_repository.dart';

class FriendService {
  final SupabaseClient _supabaseClient;
  final ChatRepository _chatRepository;

  FriendService(this._supabaseClient, this._chatRepository);

  Future<List<User>> searchUsers(String query) async {
    try {
      final List<dynamic> data = await _supabaseClient
          .from('profiles') // Assuming a 'profiles' table for user data
          .select()
          .ilike('username', '%$query%');
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendRequest(String receiverId) async {
    try {
      await _supabaseClient.rpc(
        'send_friend_request', // This RPC function needs to be created in Supabase
        params: {'receiver_id': receiverId},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      final request = await _supabaseClient
          .from('friend_requests')
          .select('sender_id, receiver_id')
          .eq('id', requestId)
          .single();

      await _supabaseClient
          .from('friend_requests')
          .update({'status': 'accepted'})
          .eq('id', requestId);

      final senderId = request['sender_id'] as String;
      final receiverId = request['receiver_id'] as String;

      // Create a chat session between the two users
      await _chatRepository.createChat(senderId, receiverId);
    } catch (e) {
      rethrow;
    }
  }

  Future<FriendRequest?> getFriendRequestById(String requestId) async {
    try {
      final data = await _supabaseClient
          .from('friend_requests')
          .select()
          .eq('id', requestId)
          .single();
      return FriendRequest.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      final data = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return User.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _supabaseClient
          .from('friend_requests')
          .update({'status': 'rejected'})
          .eq('id', requestId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      await _supabaseClient
          .from('friend_requests')
          .delete()
          .eq('id', friendId);
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<FriendRequest>> getPendingFriendRequestsStream() {
    final currentUserId = _supabaseClient.auth.currentUser?.id;
    if (currentUserId == null) return Stream.value([]);

    return _supabaseClient
        .from('friend_requests')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', currentUserId)
        .eq('status', 'pending')
        .map((maps) => maps.map((map) => FriendRequest.fromJson(map)).toList());
  }

  Future<List<User>> getAcceptedFriends() async {
    try {
      final currentUserId = _supabaseClient.auth.currentUser?.id;
      if (currentUserId == null) return [];

      // This assumes a 'friendships' table or similar for accepted friends.
      // For now, we'll fetch accepted requests where current user is either sender or receiver.
      final List<dynamic> data = await _supabaseClient
          .from('friend_requests')
          .select('*')
          .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .eq('status', 'accepted');

      final friendIds = data.map((e) {
        if (e['sender_id'] == currentUserId) {
          return e['receiver_id'];
        } else {
          return e['sender_id'];
        }
      }).toList();

      if (friendIds.isEmpty) return [];

      final List<dynamic> friendProfiles = await _supabaseClient
          .from('profiles')
          .select()
          .inFilter('id', friendIds);

      return friendProfiles.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getAcceptedFriendsStream() async {
    final currentUserId = _supabaseClient.auth.currentUser?.id;
    if (currentUserId == null) return [];

    final List<dynamic> data = await _supabaseClient.rpc(
      'get_accepted_friends',
      params: {'p_user_id': currentUserId},
    );

    return data.map((json) => User.fromJson(json)).toList();
  }
}