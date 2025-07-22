import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/Models/connection_request_model.dart';
import 'package:marriage_bereau_app/Services/connection_service.dart';
import 'package:marriage_bereau_app/Screens/profileDetailsScreen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedTabIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
      _refreshCurrentTab();
    });

    // Initialize connection service data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  // Initialize data
  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final connectionService = Provider.of<ConnectionService>(context, listen: false);
      await connectionService.initialize();
    } catch (e) {
      print("Error initializing connection data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Refresh current tab data
  void _refreshCurrentTab() {
    final connectionService = Provider.of<ConnectionService>(context, listen: false);

    switch (_selectedTabIndex) {
      case 0: // Incoming requests tab
        connectionService.loadIncomingRequests();
        break;
      case 1: // Outgoing requests tab
        connectionService.loadOutgoingRequests();
        break;
      case 2: // Updates tab
        connectionService.loadUserNotifications();
        break;
    }
  }

  // Manual refresh for all data
  Future<void> _refreshAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final connectionService = Provider.of<ConnectionService>(context, listen: false);
      await connectionService.initialize();
    } catch (e) {
      print("Error refreshing data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Connection Requests",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: pinkColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _refreshAllData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: pinkColor))
          : Column(
              children: [
                // Tab bar
                Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: pinkColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3, color: pinkColor),
                      insets: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.arrow_downward),
                        text: "Incoming",
                      ),
                      Tab(
                        icon: Icon(Icons.arrow_upward),
                        text: "Outgoing",
                      ),
                      Tab(
                        icon: Icon(Icons.notifications),
                        text: "Updates",
                      ),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildIncomingRequestsTab(),
                      _buildOutgoingRequestsTab(),
                      _buildUpdatesTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Incoming requests tab
  Widget _buildIncomingRequestsTab() {
    return Consumer<ConnectionService>(
      builder: (context, connectionService, child) {
        if (connectionService.isLoading) {
          return Center(child: CircularProgressIndicator(color: pinkColor));
        }

        final requests = connectionService.incomingRequests;
        print("DEBUG: Building incoming requests UI with ${requests.length} requests");

        return requests.isEmpty
            ? _buildEmptyState(
          "No Incoming Requests",
          "When someone sends you a connection request, it will appear here.",
          Icons.mail,
        )
            : RefreshIndicator(
          onRefresh: () => connectionService.loadIncomingRequests(),
          color: pinkColor,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              print("DEBUG: Building request card for sender ID: ${request.senderId}");

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('profiles').doc(request.senderId).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(child: CircularProgressIndicator(color: pinkColor)),
                    );
                  }

                  if (snapshot.hasError) {
                    print("DEBUG: Error loading profile for sender ID ${request.senderId}: ${snapshot.error}");
                    return Container(
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text("Error loading profile")),
                    );
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    print("DEBUG: Profile doesn't exist for sender ID: ${request.senderId}");
                    return Container(
                      height: 100,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text("Profile not found")),
                    );
                  }

                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  final String name = userData['fullName'] ?? 'Unknown User';
                  final String? imageUrl = userData['profileImage'];
                  final int age = userData['age'] ?? 0;

                  print("DEBUG: Successfully loaded profile for $name");

                  return _buildRequestCard(
                    name: name,
                    age: age,
                    imageUrl: imageUrl,
                    timestamp: request.createdAt,
                    status: request.status,
                    isIncoming: true,
                    onAccept: () => _handleAcceptRequest(connectionService, request.id),
                    onReject: () => _handleRejectRequest(connectionService, request.id),
                    onViewProfile: () => _navigateToProfile(request.senderId),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // Outgoing requests tab
  Widget _buildOutgoingRequestsTab() {
    return Consumer<ConnectionService>(
      builder: (context, connectionService, child) {
        if (connectionService.isLoading) {
          return Center(child: CircularProgressIndicator(color: pinkColor));
        }

        final requests = connectionService.outgoingRequests;
        print("DEBUG: Outgoing requests count: ${requests.length}");

        if (requests.isEmpty) {
          return _buildEmptyState(
            "No Outgoing Requests",
            "When you send connection requests to others, they will appear here.",
            Icons.send
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 8, bottom: 16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('profiles').doc(request.recipientId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator(color: pinkColor))
                    );
                  }

                  if (!snapshot.data!.exists) {
                    return SizedBox.shrink(); // Skip if profile doesn't exist
                  }

                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  final String name = userData['fullName'] ?? 'Unknown User';
                  final String? imageUrl = userData['profileImage'];
                  final int age = userData['age'] ?? 0;

                  return _buildRequestCard(
                    name: name,
                    age: age,
                    imageUrl: imageUrl,
                    timestamp: request.createdAt,
                    status: request.status,
                    isIncoming: false,
                    onViewProfile: () => _navigateToProfile(request.recipientId),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // Updates tab
  Widget _buildUpdatesTab() {
    return Consumer<ConnectionService>(
      builder: (context, connectionService, child) {
        if (connectionService.isLoading) {
          return Center(child: CircularProgressIndicator(color: pinkColor));
        }

        final notifications = connectionService.userNotifications;

        if (notifications.isEmpty) {
          return _buildEmptyState(
            "No Notifications",
            "You will see updates and connection requests here.",
            Icons.notifications_none
          );
        }

        return RefreshIndicator(
          onRefresh: () => connectionService.loadUserNotifications(),
          color: pinkColor,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final String type = notification['type'] ?? '';
              final Timestamp timestamp = notification['timestamp'] ?? Timestamp.now();
              final String senderId = notification['senderId'] ?? '';
              final String requestId = notification['requestId'] ?? '';
              final bool isRead = notification['read'] ?? false;

              // For connection requests
              if (type == 'connection_request') {
                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('profiles').doc(senderId).get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox.shrink();
                    }

                    final userData = snapshot.data!.data() as Map<String, dynamic>;
                    final String name = userData['fullName'] ?? 'Unknown User';
                    final String? imageUrl = userData['profileImage'];
                    final int age = userData['age'] ?? 0;

                    return _buildNotificationCard(
                      title: "$name, $age",
                      subtitle: "wants to connect with you",
                      imageUrl: imageUrl,
                      timestamp: timestamp,
                      isRead: isRead,
                      notificationId: notification['id'],
                      onTap: () {
                        connectionService.markNotificationAsRead(notification['id']);
                        _navigateToProfile(senderId);
                      }
                    );
                  },
                );
              }
              // For request accepted notifications
              else if (type == 'request_accepted') {
                final String recipientId = notification['recipientId'] ?? '';
                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('profiles').doc(recipientId).get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox.shrink();
                    }

                    final userData = snapshot.data!.data() as Map<String, dynamic>;
                    final String name = userData['fullName'] ?? 'Unknown User';
                    final String? imageUrl = userData['profileImage'];

                    return _buildNotificationCard(
                      title: name,
                      subtitle: "accepted your connection request",
                      imageUrl: imageUrl,
                      timestamp: timestamp,
                      isRead: isRead,
                      notificationId: notification['id'],
                      onTap: () {
                        connectionService.markNotificationAsRead(notification['id']);
                        _navigateToProfile(recipientId);
                      }
                    );
                  },
                );
              }
              // For other notification types
              return SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  // Navigate to profile details
  void _navigateToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailsScreen(userId: userId),
      ),
    ).then((_) => _refreshCurrentTab());
  }

  // Handle accept request
  Future<void> _handleAcceptRequest(ConnectionService service, String requestId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await service.acceptConnectionRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connection request accepted!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error accepting request: $e", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handle reject request
  Future<void> _handleRejectRequest(ConnectionService service, String requestId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await service.rejectConnectionRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connection request declined", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error declining request: $e", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Request card widget
  Widget _buildRequestCard({
    required String name,
    required int age,
    String? imageUrl,
    required Timestamp timestamp,
    required ConnectionStatus status,
    required bool isIncoming,
    VoidCallback? onAccept,
    VoidCallback? onReject,
    required VoidCallback onViewProfile,
  }) {
    final formattedDate = DateFormat('MMM d, yyyy').format(timestamp.toDate());

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onViewProfile,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                      child: imageUrl == null ? Icon(Icons.person, size: 30, color: Colors.grey) : null,
                      onBackgroundImageError: (exception, stackTrace) {
                        print('Error loading profile image: $exception');
                      },
                    ),
                    SizedBox(width: 16),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$name, $age",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            isIncoming ? "Sent you a connection request" : "You sent a connection request",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Indicator
                    _buildStatusIndicator(status),
                  ],
                ),

                // Action Buttons for incoming pending requests
                if (isIncoming && status == ConnectionStatus.pending) ...[
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text("Decline"),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pinkColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text("Accept"),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Status indicator widget
  Widget _buildStatusIndicator(ConnectionStatus status) {
    IconData icon;
    Color color;
    String text;

    switch (status) {
      case ConnectionStatus.accepted:
        icon = Icons.check_circle;
        color = Colors.green;
        text = "Accepted";
        break;
      case ConnectionStatus.rejected:
        icon = Icons.cancel;
        color = Colors.red;
        text = "Declined";
        break;
      case ConnectionStatus.pending:
      default:
        icon = Icons.schedule;
        color = Colors.orange;
        text = "Pending";
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Notification card widget
  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    String? imageUrl,
    required Timestamp timestamp,
    required bool isRead,
    required String notificationId,
    required VoidCallback onTap,
  }) {
    final formattedDate = DateFormat('MMM d, yyyy').format(timestamp.toDate());

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null ? Icon(Icons.person, size: 30, color: Colors.grey) : null,
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading profile image: $exception');
                  },
                ),
                SizedBox(width: 16),
                // Notification Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Unread indicator
                if (!isRead)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: pinkColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: pinkColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: pinkColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
