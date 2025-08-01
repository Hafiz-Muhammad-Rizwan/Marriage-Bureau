import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/Models/connection_request_model.dart';
import 'package:marriage_bereau_app/Services/connection_service.dart';
import 'package:provider/provider.dart';
import '../Models/user_profile_model.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final String userId;

  const ProfileDetailsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  bool _isLoading = true;
  UserProfile? _userProfile;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ConnectionRequest? _connectionRequest;
  bool _loadingRequest = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _checkConnectionRequest();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final DocumentSnapshot userDoc = await _firestore
          .collection('profiles')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userProfile = UserProfile.fromFirestore(userDoc);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile not found')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  Future<void> _checkConnectionRequest() async {
    if (_auth.currentUser?.uid == widget.userId) return; // Don't check for self

    try {
      setState(() {
        _loadingRequest = true;
      });

      final connectionService = Provider.of<ConnectionService>(context, listen: false);
      _connectionRequest = await connectionService.getRequestBetweenUsers(widget.userId);

      setState(() {
        _loadingRequest = false;
      });
    } catch (e) {
      setState(() {
        _loadingRequest = false;
      });
      print("Error checking connection request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
        backgroundColor: pinkColor,
        foregroundColor: whiteColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: pinkColor))
          : _userProfile == null
              ? Center(child: Text('Profile not available'))
              : _buildProfileDetails(),
      floatingActionButton: _buildConnectionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget? _buildConnectionButton() {
    // Don't show button for own profile
    if (_auth.currentUser?.uid == widget.userId || _userProfile == null) {
      return null;
    }

    if (_loadingRequest) {
      return FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: Colors.grey.shade300,
        label: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: pinkColor,
          ),
        ),
      );
    }

    // If no connection request exists, show the "Send Request" button
    if (_connectionRequest == null) {
      return Container(
        height: 56,
        margin: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              Color(0xFFEC407A), // Pink
              Color(0xFFD81B60), // Dark Pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: pinkColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _sendConnectionRequest,
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Send Connection Request",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // If request exists, show the status
    String statusText;
    Color statusColor;
    IconData statusIcon;
    bool isActionable = false;

    switch (_connectionRequest!.status) {
      case ConnectionStatus.pending:
        if (_connectionRequest!.senderId == _auth.currentUser?.uid) {
          statusText = "Request Pending";
          statusColor = Colors.orange;
          statusIcon = Icons.schedule;
        } else {
          statusText = "Respond to Request";
          statusColor = pinkColor;
          statusIcon = Icons.question_answer;
          isActionable = true;
        }
        break;
      case ConnectionStatus.accepted:
        statusText = "Connected";
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case ConnectionStatus.rejected:
        if (_connectionRequest!.senderId == _auth.currentUser?.uid) {
          statusText = "Request Declined";
          statusColor = Colors.red;
          statusIcon = Icons.cancel;
        } else {
          statusText = "Request Declined";
          statusColor = Colors.grey;
          statusIcon = Icons.cancel;
        }
        break;
      default:
        statusText = "Send Request";
        statusColor = pinkColor;
        statusIcon = Icons.favorite;
    }

    return Container(
      height: 56,
      margin: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.8),
            statusColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActionable ? _showRequestResponseDialog : null,
          borderRadius: BorderRadius.circular(28),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  statusIcon,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendConnectionRequest() async {
    setState(() {
      _loadingRequest = true;
    });

    try {
      final connectionService = Provider.of<ConnectionService>(context, listen: false);
      bool success = await connectionService.sendConnectionRequest(widget.userId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connection request sent!"),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the request status
        await _checkConnectionRequest();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send request. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _loadingRequest = false;
      });
    }
  }

  void _showRequestResponseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Connection Request"),
        content: Text("${_userProfile?.fullName} wants to connect with you. Would you like to accept?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _respondToRequest(false);
            },
            child: Text(
              "Decline",
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _respondToRequest(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: pinkColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text("Accept"),
          ),
        ],
      ),
    );
  }

  Future<void> _respondToRequest(bool accept) async {
    if (_connectionRequest == null) return;

    setState(() {
      _loadingRequest = true;
    });

    try {
      final connectionService = Provider.of<ConnectionService>(context, listen: false);
      bool success = accept
          ? await connectionService.acceptConnectionRequest(_connectionRequest!.id)
          : await connectionService.rejectConnectionRequest(_connectionRequest!.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(accept ? "Request accepted!" : "Request declined."),
            backgroundColor: accept ? Colors.green : Colors.grey,
          ),
        );

        // Refresh the request status
        await _checkConnectionRequest();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to respond to request. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _loadingRequest = false;
      });
    }
  }

  // Helper method to get formatted children details as a string
  String _getChildrenDetailsText() {
    if (_userProfile!.children == null) {
      return 'Not specified';
    }

    if (_userProfile!.children != 'Yes') {
      return _userProfile!.children!;
    }

    // If children is "Yes"
    String childrenDetails = 'Yes';

    // Debug information to check what's coming from database
    print("Boys Count: ${_userProfile!.boysCount}");
    print("Girls Count: ${_userProfile!.girlsCount}");

    if ((_userProfile!.boysCount != null && _userProfile!.boysCount!.isNotEmpty) ||
        (_userProfile!.girlsCount != null && _userProfile!.girlsCount!.isNotEmpty)) {
      childrenDetails += ' (';

      if (_userProfile!.boysCount != null && _userProfile!.boysCount!.isNotEmpty) {
        childrenDetails += '${_userProfile!.boysCount} boys';
      }

      if (_userProfile!.boysCount != null && _userProfile!.girlsCount != null &&
          _userProfile!.boysCount!.isNotEmpty && _userProfile!.girlsCount!.isNotEmpty) {
        childrenDetails += ', ';
      }

      if (_userProfile!.girlsCount != null && _userProfile!.girlsCount!.isNotEmpty) {
        childrenDetails += '${_userProfile!.girlsCount} girls';
      }

      childrenDetails += ')';
    }

    return childrenDetails;
  }

  // Helper method to get formatted siblings details as a string
  String _getSiblingsDetailsText() {
    if (_userProfile!.hasSiblings == null) {
      return 'Not specified';
    }

    if (_userProfile!.hasSiblings == false) {
      return 'No siblings';
    }

    // If has siblings is true
    String siblingsDetails = 'Yes';

    if (_userProfile!.totalSiblings != null) {
      siblingsDetails += ' (${_userProfile!.totalSiblings} in total';

      if (_userProfile!.brothers != null || _userProfile!.sisters != null) {
        siblingsDetails += ': ';

        if (_userProfile!.brothers != null && _userProfile!.brothers! > 0) {
          siblingsDetails += '${_userProfile!.brothers} brother${_userProfile!.brothers! > 1 ? 's' : ''}';
        }

        if (_userProfile!.brothers != null && _userProfile!.brothers! > 0 &&
            _userProfile!.sisters != null && _userProfile!.sisters! > 0) {
          siblingsDetails += ', ';
        }

        if (_userProfile!.sisters != null && _userProfile!.sisters! > 0) {
          siblingsDetails += '${_userProfile!.sisters} sister${_userProfile!.sisters! > 1 ? 's' : ''}';
        }
      }

      siblingsDetails += ')';
    }

    return siblingsDetails;
  }

  // Helper method to get formatted parent status information
  String _getParentStatusText(String parent) {
    if (parent == 'Father') {
      return _userProfile!.isFatherAlive == null ? 'Not specified' :
             (_userProfile!.isFatherAlive! ? 'Yes' : 'No');
    } else { // Mother
      return _userProfile!.isMotherAlive == null ? 'Not specified' :
             (_userProfile!.isMotherAlive! ? 'Yes' : 'No');
    }
  }

  Widget _buildProfileDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header with Image
          Center(
            child: Column(
              children: [
                _userProfile!.profileImage != null
                    ? CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(_userProfile!.profileImage!),
                      )
                    : const CircleAvatar(
                        radius: 60,
                        child: Icon(Icons.person, size: 60),
                      ),
                const SizedBox(height: 16),
                Text(
                  _userProfile!.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_userProfile!.age} years • ${_userProfile!.gender}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),

          // Basic Information
          _buildSectionTitle('Basic Information'),
          _buildInfoRow('Date of Birth', DateFormat('dd MMM yyyy').format(_userProfile!.dateOfBirth.toDate())),
          _buildInfoRow('Height', _userProfile!.height ?? 'Not specified'),
          _buildInfoRow('Marital Status', _userProfile!.maritalStatus ?? 'Not specified'),
          _buildInfoRow('Religion', _userProfile!.sect ?? 'Not specified'),
          _buildInfoRow('Education', _userProfile!.educationLevel ?? 'Not specified'),
          _buildInfoRow('Profession', _userProfile!.profession ?? 'Not specified'),
          _buildInfoRow('Children', _getChildrenDetailsText()),
          _buildInfoRow('Siblings', _getSiblingsDetailsText()),
          _buildInfoRow('Father', _getParentStatusText('Father')),
          _buildInfoRow('Mother', _getParentStatusText('Mother')),
          _buildInfoRow('Guardian', _userProfile!.guardianType ?? 'Not specified'),
          if (_userProfile!.nationalities != null && _userProfile!.nationalities!.isNotEmpty)
            _buildInfoRow('Nationality', _userProfile!.nationalities!.join(', ')),
          _buildInfoRow('Willing to Move Abroad', _userProfile!.moveAbroad ?? 'Not specified'),
          const SizedBox(height: 16),
          const Divider(),

          // Lifestyle
          _buildSectionTitle('Lifestyle'),
          _buildInfoRow('Smoking', _userProfile!.smoking ?? 'Not specified'),
          _buildInfoRow('Alcohol', _userProfile!.alcohol ?? 'Not specified'),
          _buildInfoRow('Home Type', _userProfile!.homeType ?? 'Not specified'),
          _buildInfoRow(
            'Address',
            '${_userProfile!.address}, ${_userProfile!.city }, ${_userProfile!.country }'.trim() ?? "Not Specified"),
          const SizedBox(height: 16),
          const Divider(),

          // Interests
          if (_userProfile!.interests != null && _userProfile!.interests!.isNotEmpty) ...[
            _buildSectionTitle('Interests'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _userProfile!.interests!.map((interest) {
                return Chip(
                  label: Text(interest),
                  backgroundColor: pinkColor.withOpacity(0.1),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: pinkColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
