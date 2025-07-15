part of 'friends_bloc.dart';

abstract class FriendsEvent extends Equatable {
  const FriendsEvent();

  @override
  List<Object> get props => [];
}

class SearchUsers extends FriendsEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object> get props => [query];
}

class SendFriendRequest extends FriendsEvent {
  final String receiverId;

  const SendFriendRequest(this.receiverId);

  @override
  List<Object> get props => [receiverId];
}

class AcceptFriendRequest extends FriendsEvent {
  final String requestId;

  const AcceptFriendRequest({required this.requestId});

  @override
  List<Object> get props => [requestId];
}

class RejectFriendRequest extends FriendsEvent {
  final String requestId;

  const RejectFriendRequest({required this.requestId});

  @override
  List<Object> get props => [requestId];
}

class RemoveFriend extends FriendsEvent {
  final String friendId;

  const RemoveFriend(this.friendId);

  @override
  List<Object> get props => [friendId];
}

class LoadFriends extends FriendsEvent {}

class LoadPendingRequests extends FriendsEvent {}