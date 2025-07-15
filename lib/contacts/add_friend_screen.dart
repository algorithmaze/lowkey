import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lowkey/contacts/friends_bloc.dart';


class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Add Friend'),
        previousPageTitle: 'Contacts',
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                onChanged: (query) {
                  context.read<FriendsBloc>().add(SearchUsers(query));
                },
                placeholder: 'Search by username or phone',
              ),
            ),
            Expanded(
              child: BlocConsumer<FriendsBloc, FriendsState>(
                listener: (context, state) {
                  if (state is RequestSent) {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Friend Request Sent'),
                        content: const Text('Your friend request has been sent.'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  } else if (state is FriendsError) {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('Error'),
                        content: Text(state.message),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('OK'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is FriendsLoading) {
                    return const Center(child: CupertinoActivityIndicator());
                  } else if (state is SearchResults) {
                    if (state.users.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }
                    return ListView.builder(
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return CupertinoListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null
                                ? const Icon(CupertinoIcons.person)
                                : null,
                          ),
                          title: Text(user.username),
                          trailing: CupertinoButton(
                            onPressed: () {
                              context.read<FriendsBloc>().add(SendFriendRequest(user.id));
                            },
                            child: const Text('Add'),
                          ),
                        );
                      },
                    );
                  } else if (state is FriendsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(child: Text('Search for users.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}