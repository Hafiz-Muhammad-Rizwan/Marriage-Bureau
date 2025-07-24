import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
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
  List<UserProfile> _filteredProfiles = [];
  Set<String> _favoriteProfiles = {};
  bool _isLoading = true;
  String? _currentUserGender;

  // Filter related variables
  RangeValues _ageRange = const RangeValues(18, 60);
  String? _selectedMaritalStatus;
  String? _selectedCaste;
  String? _selectedSect;
  bool _filtersApplied = false;

  // Marital status options - matching the options in MaritalStatusProvider
  final List<String> _maritalStatusOptions = [
    'All',
    'Never married',
    'Divorced',
    'Widowed',
    'Married',
  ];

  // We'll populate these from the Sign Up Logic providers
  List<String> _casteOptions = ['All'];
  List<String> _sectOptions = ['All'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Initialize filter options from providers
    _initializeFilterOptions();
  }

  void _initializeFilterOptions() {
    // Get caste options from CasteProvider
    final casteProvider = Provider.of<CasteProvider>(context, listen: false);
    _casteOptions = ['All'];
    _casteOptions.addAll(casteProvider.castes.map((caste) => caste.name).toList());

    // Get sect options from SectProvider
    final sectProvider = Provider.of<SectProvider>(context, listen: false);
    _sectOptions = ['All'];
    _sectOptions.addAll(sectProvider.sects.map((sect) => sect.name).toList());
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
          _filteredProfiles = tempProfiles; // Initialize filtered profiles
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

  void _applyFilters() {
    setState(() {
      _filtersApplied = true;
      _filteredProfiles = _profiles.where((profile) {
        final ageValid = profile.age != null &&
            profile.age! >= _ageRange.start &&
            profile.age! <= _ageRange.end;
        final maritalStatusValid = _selectedMaritalStatus == null ||
            _selectedMaritalStatus == 'All' ||
            profile.maritalStatus == _selectedMaritalStatus;
        final casteValid = _selectedCaste == null ||
            _selectedCaste == 'All' ||
            profile.caste == _selectedCaste;
        final sectValid = _selectedSect == null ||
            _selectedSect == 'All' ||
            profile.sect == _selectedSect;

        return ageValid && maritalStatusValid && casteValid && sectValid;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _ageRange = const RangeValues(18, 60);
      _selectedMaritalStatus = null;
      _selectedCaste = null;
      _selectedSect = null;
      _filtersApplied = false;
      _filteredProfiles = _profiles; // Reset to all profiles
    });
  }

  void _showFilterDialog() {
    // Create temporary variables to hold filter values during dialog
    RangeValues tempAgeRange = _ageRange;
    String? tempMaritalStatus = _selectedMaritalStatus;
    String? tempCaste = _selectedCaste;
    String? tempSect = _selectedSect;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.filter_list, color: pinkColor),
                  const SizedBox(width: 10),
                  Text(
                    "Filter Profiles",
                    style: TextStyle(
                      color: pinkColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Age Range Section
                      _buildFilterSectionTitle("Age Range"),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${tempAgeRange.start.round()} years",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${tempAgeRange.end.round()} years",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            RangeSlider(
                              values: tempAgeRange,
                              min: 18,
                              max: 100,
                              divisions: 82,
                              activeColor: pinkColor,
                              inactiveColor: Colors.grey[300],
                              labels: RangeLabels(
                                tempAgeRange.start.round().toString(),
                                tempAgeRange.end.round().toString(),
                              ),
                              onChanged: (values) {
                                setState(() {
                                  tempAgeRange = values;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Marital Status Section
                      _buildFilterSectionTitle("Marital Status"),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: tempMaritalStatus,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: pinkColor),
                            hint: Text("Select Marital Status"),
                            items: _maritalStatusOptions.map((status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                tempMaritalStatus = value;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Caste Section
                      _buildFilterSectionTitle("Caste"),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: tempCaste,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: pinkColor),
                            hint: Text("Select Caste"),
                            items: _casteOptions.map((caste) {
                              return DropdownMenuItem<String>(
                                value: caste,
                                child: Text(caste),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                tempCaste = value;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sect Section
                      _buildFilterSectionTitle("Sect"),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: tempSect,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down, color: pinkColor),
                            hint: Text("Select Sect"),
                            items: _sectOptions.map((sect) {
                              return DropdownMenuItem<String>(
                                value: sect,
                                child: Text(sect),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                tempSect = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () {
                    // Reset temp filters
                    Navigator.of(context).pop();
                    _resetFilters();
                  },
                  icon: Icon(Icons.refresh, color: Colors.grey[700]),
                  label: Text(
                    "Reset",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Apply the temp filters to actual filters
                    _ageRange = tempAgeRange;
                    _selectedMaritalStatus = tempMaritalStatus;
                    _selectedCaste = tempCaste;
                    _selectedSect = tempSect;
                    Navigator.of(context).pop();
                    _applyFilters();
                  },
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text(
                    "Apply",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pinkColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: pinkColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
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
          // Add filter button
          IconButton(
            onPressed: _showFilterDialog,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list, color: Colors.white),
                if (_filtersApplied)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
          : _filteredProfiles.isEmpty
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
                  itemCount: _filteredProfiles.length,
                  padding: EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final profile = _filteredProfiles[index];
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
