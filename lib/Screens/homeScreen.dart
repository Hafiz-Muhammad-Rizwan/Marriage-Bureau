import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/Models/user_profile_model.dart';
import 'package:marriage_bereau_app/RegistrationScreen/Editing%20Screen.dart';
import 'package:marriage_bereau_app/Screens/profileDetailsScreen.dart';
import 'package:marriage_bereau_app/Services/profile_service.dart';
import 'package:provider/provider.dart';
import 'package:marriage_bereau_app/Screens/notificationsScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserProfile> _profiles = [];
  Set<String> _favoriteProfiles = {};
  bool _isLoading = true;
  String? _currentUserGender;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user profile to determine gender for filtering
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return;
      }

      // Get user profile data including gender
      final DocumentSnapshot userDoc = await _firestore
          .collection('profiles')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        _currentUserGender = data['gender'];

        // Load favorite profiles
        DocumentSnapshot favoritesDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('favorites')
            .doc('profileFavorites')
            .get();

        if (favoritesDoc.exists && favoritesDoc.data() != null) {
          final data = favoritesDoc.data() as Map<String, dynamic>;
          if (data.containsKey('profiles')) {
            setState(() {
              _favoriteProfiles = Set<String>.from(data['profiles']);
            });
          }
        }

        // Load profiles of opposite gender
        final oppositeGender = _currentUserGender == 'Male' ? 'Female' : 'Male';
        final QuerySnapshot profilesSnapshot = await _firestore
            .collection('profiles')
            .where('gender', isEqualTo: oppositeGender)
            .where('isVisible', isEqualTo: true)
            .limit(20)
            .get();

        List<UserProfile> tempProfiles = [];
        for (var doc in profilesSnapshot.docs) {
          final profile = UserProfile.fromFirestore(doc);
          tempProfiles.add(profile);
        }

        setState(() {
          _profiles = tempProfiles;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite(String profileId) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    setState(() {
      if (_favoriteProfiles.contains(profileId)) {
        _favoriteProfiles.remove(profileId);
      } else {
        _favoriteProfiles.add(profileId);
      }
    });

    // Update favorites in Firestore
    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .doc('profileFavorites')
          .set({
        'profiles': _favoriteProfiles.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _favoriteProfiles.contains(profileId)
                ? 'Added to favorites'
                : 'Removed from favorites',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: pinkColor,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print("Error updating favorites: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: pinkColor,
        title: const Text(
          "Explore",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditingScreen())
              ).then((_) {
                // Refresh data when returning from editing screen
                _loadUserData();
              });
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: pinkColor),
            )
          : _profiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        "No profiles found",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "We couldn't find any profiles matching your criteria",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pinkColor,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Refresh",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _profiles.length,
                  padding: EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final profile = _profiles[index];
                    final bool isFavorite = _favoriteProfiles.contains(profile.userId);

                    return Card(
                      margin: EdgeInsets.only(bottom: 15),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileDetailsScreen(userId: profile.userId),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  // Profile image
                                  Container(
                                    height: 400,
                                    width: double.infinity,
                                    child: profile.profileImage != null && profile.profileImage!.isNotEmpty
                                        ? Image.network(
                                            profile.profileImage!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              print("Error loading image: $error for URL: ${profile.profileImage}");
                                              return Image.asset(
                                                "assets/Images/man.jpeg",
                                                fit: BoxFit.cover,
                                              );
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                  color: pinkColor,
                                                ),
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            "assets/Images/man.jpeg",
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  // Gradient overlay
                                  Container(
                                    height: 400,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                  // Favorite button
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: InkWell(
                                      onTap: () => _toggleFavorite(profile.userId),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isFavorite ? Icons.star : Icons.star_border,
                                          color: isFavorite ? Colors.amber : Colors.grey,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Profile info at bottom
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "${profile.fullName}, ${profile.age}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              profile.isVerified
                                                  ? Icon(
                                                      Icons.verified,
                                                      color: Colors.blueAccent,
                                                      size: 24,
                                                    )
                                                  : SizedBox(),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on, color: Colors.white, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                // You could add location data to your profile model
                                                "Location information",
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _buildTag("Age: ${profile.age}", Colors.green),
                                              if (profile.profession != null)
                                                _buildTag(profile.profession!, Colors.blueAccent),
                                              if (profile.height != null)
                                                _buildTag("Height: ${profile.height}", Colors.orange),
                                              if (profile.maritalStatus != null)
                                                _buildTag(profile.maritalStatus!, Colors.teal),
                                              if (profile.nationalities != null && profile.nationalities!.isNotEmpty)
                                                _buildTag(profile.nationalities!.first, Colors.indigo),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildActionButton(Icons.clear, Colors.white, Colors.pinkAccent, () {
                                          // Skip profile action
                                        }),
                                        _buildActionButton(
                                          Icons.star,
                                          isFavorite ? Colors.amber : Colors.white,
                                          isFavorite ? Colors.white : Colors.pinkAccent,
                                          () => _toggleFavorite(profile.userId)
                                        ),
                                        _buildActionButton(Icons.favorite, Colors.white, Colors.redAccent, () {
                                          // Like profile action
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    );
                    },
                  ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => buildFavoritesSheet(),
          );
        },
        backgroundColor: pinkColor,
        child: Icon(Icons.favorite, color: Colors.white),
      ),
    );
  }

  Widget buildFavoritesSheet() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Your Favorites",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: pinkColor,
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: _favoriteProfiles.isEmpty
                ? Center(
                    child: Text(
                      "You haven't added any favorites yet",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _profiles.where((p) => _favoriteProfiles.contains(p.userId)).length,
                    itemBuilder: (context, index) {
                      final favoriteProfile = _profiles.where((p) => _favoriteProfiles.contains(p.userId)).toList()[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: favoriteProfile.profileImage != null && favoriteProfile.profileImage!.isNotEmpty
                              ? NetworkImage(favoriteProfile.profileImage!)
                              : AssetImage("assets/Images/man.jpeg") as ImageProvider,
                          radius: 25,
                          onBackgroundImageError: (exception, stackTrace) {
                            print("Error loading favorite image: $exception for URL: ${favoriteProfile.profileImage}");
                          },
                        ),
                        title: Text(
                          favoriteProfile.fullName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Age: ${favoriteProfile.age}"),
                        trailing: IconButton(
                          icon: Icon(Icons.star, color: Colors.amber),
                          onPressed: () => _toggleFavorite(favoriteProfile.userId),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to profile details screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileDetailsScreen(userId: favoriteProfile.userId),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: bgColor,
        child: Icon(
          icon,
          color: iconColor,
          size: 28,
        ),
      ),
    );
  }
}
