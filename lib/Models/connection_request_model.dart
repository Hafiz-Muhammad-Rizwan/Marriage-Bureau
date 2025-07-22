import 'package:cloud_firestore/cloud_firestore.dart';

enum ConnectionStatus {
  pending,
  accepted,
  rejected
}

class ConnectionRequest {
  final String id;
  final String senderId;
  final String recipientId;
  final ConnectionStatus status;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final String? message;

  ConnectionRequest({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.message,
  });

  factory ConnectionRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ConnectionRequest(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      recipientId: data['recipientId'] ?? '',
      status: _statusFromString(data['status'] ?? 'pending'),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
      message: data['message'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recipientId': recipientId,
      'status': _statusToString(status),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'message': message,
    };
  }

  static ConnectionStatus _statusFromString(String status) {
    switch (status) {
      case 'accepted':
        return ConnectionStatus.accepted;
      case 'rejected':
        return ConnectionStatus.rejected;
      case 'pending':
      default:
        return ConnectionStatus.pending;
    }
  }

  static String _statusToString(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.accepted:
        return 'accepted';
      case ConnectionStatus.rejected:
        return 'rejected';
      case ConnectionStatus.pending:
      default:
        return 'pending';
    }
  }
}
