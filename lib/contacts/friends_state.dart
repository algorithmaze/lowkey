part of 'friends_bloc.dart';

abstract class FriendsState extends Equatable {
  const FriendsState();

  @override
  List<Object> get props => [];
}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<User> friends;

  const FriendsLoaded(this.friends);

  @override
  List<Object> get props => [friends];
}

class SearchResults extends FriendsState {
  final List<User> users;

  const SearchResults(this.users);

  @override
  List<Object> get props => [users];
}

class RequestSent extends FriendsState {}

class FriendRequestAccepted extends FriendsState {}

class FriendRequestAcceptedWithChat extends FriendsState {
  final String chatId;
  final String chatPartnerId;
  final String chatPartnerUsername;

  const FriendRequestAcceptedWithChat({
    required this.chatId,
    required this.chatPartnerId,
    required this.chatPartnerUsername,
  });

  @override
  List<Object> get props => [chatId, chatPartnerId, chatPartnerUsername];
}

class RequestRejected extends FriendsState {}

class FriendRemoved extends FriendsState {}

class PendingRequestsLoaded extends FriendsState {
  final List<FriendRequest> requests;

  const PendingRequestsLoaded(this.requests);

  @override
  List<Object> get props => [requests];
}

class FriendsError extends FriendsState {
  final String message;

  const FriendsError(this.message);

  @override
  List<Object> get props => [message];
}