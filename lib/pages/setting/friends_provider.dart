import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _friends = [];

  List<DocumentSnapshot> get friends => _friends;

  Future<void> fetchFriends() async {
    try {
      print("fetchFriends() called");
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('friends')
          .get();
      _friends = snapshot.docs;
      notifyListeners();
    } catch (e) {
      print('Error fetching friends: $e');
    }
  }

  Future<void> addFriend(String friendEmail) async {
    try {
      QuerySnapshot friendQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: friendEmail)
          .get();

      if (friendQuery.docs.isEmpty) {
        throw Exception('User with this email not found.');
      }

      String friendUid = friendQuery.docs.first.id;
      String currentUid = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .doc(friendUid)
          .set({});

      await _firestore
          .collection('users')
          .doc(friendUid)
          .collection('friends')
          .doc(currentUid)
          .set({});

      fetchFriends(); // Refresh the friend list
    } catch (e) {
      print('Error adding friend: $e');
      throw e; // Re-throw the error to be handled in the UI
    }
  }

  Future<void> deleteFriend(String friendUid) async {
    String currentUid = _auth.currentUser!.uid;
    try {
      await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .doc(friendUid)
          .delete();

      await _firestore
          .collection('users')
          .doc(friendUid)
          .collection('friends')
          .doc(currentUid)
          .delete();

      fetchFriends(); // Refresh the friend list
    } catch (e) {
      print('Error deleting friend: $e');
      throw e; // Re-throw the error to be handled in the UI
    }
  }
}
