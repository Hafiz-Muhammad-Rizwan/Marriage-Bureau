import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Models/connection_request_model.dart';

class ConnectionService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ConnectionRequest> _incomingRequests = [];
  List<ConnectionRequest> _outgoingRequests = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _userNotifications = [];

  List<ConnectionRequest> get incomingRequests => _incomingRequests;
  List<ConnectionRequest> get outgoingRequests => _outgoingRequests;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get userNotifications => _userNotifications;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if a request has already been sent to a specific user
  Future<ConnectionRequest?> getRequestBetweenUsers(String otherUserId) async {
    if (currentUserId == null) return null;

    try {
      // Check for outgoing request
      QuerySnapshot outgoingSnapshot = await _firestore
          .collection('connectionRequests')
          .where('senderId', isEqualTo: currentUserId)
          .where('recipientId', isEqualTo: otherUserId)
          .limit(1)
          .get();

      if (outgoingSnapshot.docs.isNotEmpty) {
        return ConnectionRequest.fromFirestore(outgoingSnapshot.docs.first);
      }

      // Check for incoming request
      QuerySnapshot incomingSnapshot = await _firestore
          .collection('connectionRequests')
          .where('senderId', isEqualTo: otherUserId)
          .where('recipientId', isEqualTo: currentUserId)
          .limit(1)
          .get();

      if (incomingSnapshot.docs.isNotEmpty) {
        return ConnectionRequest.fromFirestore(incomingSnapshot.docs.first);
      }

      return null;
    } catch (e) {
      print("Error checking connection request: $e");
      return null;
    }
  }

  // Send a connection request
  Future<bool> sendConnectionRequest(String recipientId, {String? message}) async {
    if (currentUserId == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      // Check if request already exists
      ConnectionRequest? existingRequest = await getRequestBetweenUsers(recipientId);
      if (existingRequest != null) {
        _isLoading = false;
        notifyListeners();
        return false; // Request already exists
      }

      // Create new request
      final request = ConnectionRequest(
        id: 'temp',
        senderId: currentUserId!,
        recipientId: recipientId,
        status: ConnectionStatus.pending,
        createdAt: Timestamp.now(),
        message: message,
      );

      // Save to Firestore
      DocumentReference docRef = await _firestore
          .collection('connectionRequests')
          .add(request.toMap());

      // Add to notification collection for recipient
      await _firestore
          .collection('users')
          .doc(recipientId)
          .collection('notifications')
          .add({
        'type': 'connection_request',
        'requestId': docRef.id,
        'senderId': currentUserId,
        'timestamp': Timestamp.now(),
        'read': false,
      });

      // Update local list
      await loadOutgoingRequests();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error sending connection request: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Accept a connection request
  Future<bool> acceptConnectionRequest(String requestId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update request status
      await _firestore
          .collection('connectionRequests')
          .doc(requestId)
          .update({
        'status': 'accepted',
        'updatedAt': Timestamp.now(),
      });

      // Get the request data to know the sender
      DocumentSnapshot requestDoc = await _firestore
          .collection('connectionRequests')
          .doc(requestId)
          .get();

      if (requestDoc.exists) {
        Map<String, dynamic> data = requestDoc.data() as Map<String, dynamic>;
        String senderId = data['senderId'];

        // Add notification for sender
        await _firestore
            .collection('users')
            .doc(senderId)
            .collection('notifications')
            .add({
          'type': 'request_accepted',
          'requestId': requestId,
          'recipientId': currentUserId,
          'timestamp': Timestamp.now(),
          'read': false,
        });
      }

      // Refresh lists
      await loadIncomingRequests();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error accepting connection request: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reject a connection request
  Future<bool> rejectConnectionRequest(String requestId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update request status
      await _firestore
          .collection('connectionRequests')
          .doc(requestId)
          .update({
        'status': 'rejected',
        'updatedAt': Timestamp.now(),
      });

      // Refresh lists
      await loadIncomingRequests();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error rejecting connection request: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load outgoing connection requests
  Future<void> loadOutgoingRequests() async {
    if (currentUserId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // First attempt to use the proper query with ordering
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('connectionRequests')
            .where('senderId', isEqualTo: currentUserId)
            .orderBy('createdAt', descending: true)
            .get();

        _outgoingRequests = snapshot.docs
            .map((doc) => ConnectionRequest.fromFirestore(doc))
            .toList();
      } catch (indexError) {
        // If index error occurs, fallback to a simpler query without ordering
        print("Index error on outgoing requests. Trying fallback query: $indexError");

        QuerySnapshot snapshot = await _firestore
            .collection('connectionRequests')
            .where('senderId', isEqualTo: currentUserId)
            .get();

        _outgoingRequests = snapshot.docs
            .map((doc) => ConnectionRequest.fromFirestore(doc))
            .toList();

        // Sort locally instead
        _outgoingRequests.sort((a, b) =>
          b.createdAt.compareTo(a.createdAt)
        );

        // Print the index creation URL to console for admin to create later
        print("To improve performance, please create the required index: " +
              "https://console.firebase.google.com/v1/r/project/marriage-app-71ea3/firestore/indexes");
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error loading outgoing requests: $e");
      // Set empty list rather than leaving previous data
      _outgoingRequests = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load incoming connection requests
  Future<void> loadIncomingRequests() async {
    if (currentUserId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // First attempt to use the proper query with ordering
      try {
        print("DEBUG: Attempting to load incoming requests for user: $currentUserId");
        QuerySnapshot snapshot = await _firestore
            .collection('connectionRequests')
            .where('recipientId', isEqualTo: currentUserId)
            .orderBy('createdAt', descending: true)
            .get();

        _incomingRequests = snapshot.docs
            .map((doc) => ConnectionRequest.fromFirestore(doc))
            .toList();

        print("DEBUG: Successfully loaded ${_incomingRequests.length} incoming requests");
      } catch (indexError) {
        // If index error occurs, fallback to a simpler query without ordering
        print("DEBUG: Index error on incoming requests. Error details: $indexError");
        print("DEBUG: Trying fallback query without ordering");

        QuerySnapshot snapshot = await _firestore
            .collection('connectionRequests')
            .where('recipientId', isEqualTo: currentUserId)
            .get();

        _incomingRequests = snapshot.docs
            .map((doc) => ConnectionRequest.fromFirestore(doc))
            .toList();

        // Sort locally instead
        _incomingRequests.sort((a, b) =>
          b.createdAt.compareTo(a.createdAt)
        );

        print("DEBUG: Fallback query loaded ${_incomingRequests.length} incoming requests");
        // Print the index creation URL to console for admin to create later
        print("To improve performance, please create the required index: " +
              "https://console.firebase.google.com/v1/r/project/marriage-app-71ea3/firestore/indexes");
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error loading incoming requests: $e");
      // Set empty list rather than leaving previous data
      _incomingRequests = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user notifications
  Future<void> loadUserNotifications() async {
    if (currentUserId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      _userNotifications = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Error loading user notifications: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get number of unread notifications
  Future<int> getUnreadNotificationsCount() async {
    if (currentUserId == null) return 0;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print("Error getting unread notifications count: $e");
      return 0;
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    if (currentUserId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  // Initialize service (load both incoming and outgoing requests)
  Future<void> initialize() async {
    if (currentUserId == null) return;

    await loadIncomingRequests();
    await loadOutgoingRequests();
    await loadUserNotifications();
  }
}
