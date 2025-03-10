import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'friends_provider.dart'; // Import your FriendsProvider

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Initialize _firestore here

  @override
  void initState() {
    super.initState();
    Provider.of<FriendsProvider>(context, listen: false).fetchFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friends')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Friend\'s Email'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Provider.of<FriendsProvider>(context, listen: false)
                      .addFriend(_emailController.text.trim());
                  _emailController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Friend added successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text('Add Friend'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Consumer<FriendsProvider>(
                builder: (context, friendsProvider, child) {
                  if (friendsProvider.friends.isEmpty) {
                    return Center(child: Text('You have no friends yet.'));
                  }

                  return ListView.builder(
                    itemCount: friendsProvider.friends.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot friendDoc =
                          friendsProvider.friends[index];
                      return FutureBuilder<DocumentSnapshot>(
                        future: _firestore
                            .collection('users')
                            .doc(friendDoc.id)
                            .get(), // Using initialized _firestore
                        builder: (context, friendSnapshot) {
                          if (friendSnapshot.hasData &&
                              friendSnapshot.data!.exists) {
                            String friendName =
                                friendSnapshot.data!['username'] ??
                                    'Unknown User';
                            return ListTile(
                              title: Text(friendName),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  try {
                                    await Provider.of<FriendsProvider>(context,
                                            listen: false)
                                        .deleteFriend(friendDoc.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Friend deleted successfully!')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to delete friend. Please try again.')),
                                    );
                                  }
                                },
                              ),
                            );
                          } else {
                            return ListTile(
                              title: Text('Loading friend...'),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
