import 'package:lowkey/contacts/friend_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lowkey/contacts/friend_service.dart';
import 'package:lowkey/contacts/user.dart';
import 'package:lowkey/chat/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import 'dart:async';

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final FriendService _friendService;
  final ChatRepository _chatRepository;

  FriendsBloc({
    required FriendService friendService,
    required ChatRepository chatRepository,
  })  : _friendService = friendService,
        _chatRepository = chatRepository,
        super(FriendsInitial()) {
    on<SearchUsers>(_onSearchUsers);
    on<SendFriendRequest>(_onSendFriendRequest);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<RejectFriendRequest>(_onRejectFriendRequest);
    on<RemoveFriend>(_onRemoveFriend);
    on<LoadFriends>(_onLoadFriends);
    on<LoadPendingRequests>(_onLoadPendingRequests);
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      final users = await _friendService.searchUsers(event.query);
      emit(SearchResults(users));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequest event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      await _friendService.sendRequest(event.receiverId);
      emit(RequestSent());
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> _onAcceptFriendRequest(
    AcceptFriendRequest event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      await _friendService.acceptRequest(event.requestId);
      final request = await _friendService.getFriendRequestById(event.requestId);
      if (request != null) {
        final chatPartnerId = request.senderId == supabase_flutter.Supabase.instance.client.auth.currentUser!.id ? request.receiverId : request.senderId;
        final chatPartner = await _friendService.getUserById(chatPartnerId);
        if (chatPartner != null) {
          final chatId = await _chatRepository.createChat(request.senderId, request.receiverId);
          emit(FriendRequestAcceptedWithChat(
            chatId: chatId,
            chatPartnerId: chatPartner.id,
            chatPartnerUsername: chatPartner.username,
          ));
        }
      }
      add(LoadPendingRequests()); // Reload pending requests after acceptance
      add(LoadFriends()); // Reload friends after acceptance
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> _onRejectFriendRequest(
    RejectFriendRequest event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      await _friendService.rejectRequest(event.requestId);
      emit(RequestRejected());
      add(LoadPendingRequests()); // Reload pending requests after rejection
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> _onRemoveFriend(
    RemoveFriend event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      await _friendService.removeFriend(event.friendId);
      emit(FriendRemoved());
      add(LoadFriends()); // Reload friends after removal
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  Future<void> _onLoadFriends(
    LoadFriends event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      final friends = await _friendService.getAcceptedFriendsStream();
      emit(FriendsLoaded(friends));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }

  

  Future<void> _onLoadPendingRequests(
    LoadPendingRequests event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());
    try {
      final requests = await _friendService.getPendingFriendRequests();
      emit(PendingRequestsLoaded(requests));
    } catch (e) {
      emit(FriendsError(e.toString()));
    }
  }
}
