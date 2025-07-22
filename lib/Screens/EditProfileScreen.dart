import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/Essentials/fontSizes.dart';
import 'package:marriage_bereau_app/Models/user_profile_model.dart';
import 'package:marriage_bereau_app/Services/profile_service.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;

  const EditProfileScreen({Key? key, required this.userProfile}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isLoading = false;
  String _errorMessage = '';
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _auth;

  // Initialize providers
  late ParentsStatusProvider _parentsStatusProvider;
  late HeightProvider _heightProvider;
  late MaritalStatusProvider _maritalStatusProvider;
  late SmokingProvider _smokingProvider;
  late AlcoholConsumptionProvider _alcoholProvider;
  late ChildrenProvider _childrenProvider;
  late MoveAbroadProvider _moveAbroadProvider;
  late SiblingsProvider _siblingsProvider;
  late CasteProvider _casteProvider;
  late SectProvider _sectProvider;
  late EducationLevelProvider _educationLevelProvider;
  late ProfessionProvider _professionProvider;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() {
    // Initialize all providers with existing data
    _parentsStatusProvider = Provider.of<ParentsStatusProvider>(context, listen: false);
    _heightProvider = Provider.of<HeightProvider>(context, listen: false);
    _maritalStatusProvider = Provider.of<MaritalStatusProvider>(context, listen: false);
    _smokingProvider = Provider.of<SmokingProvider>(context, listen: false);
    _alcoholProvider = Provider.of<AlcoholConsumptionProvider>(context, listen: false);
    _childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
    _moveAbroadProvider = Provider.of<MoveAbroadProvider>(context, listen: false);
    _siblingsProvider = Provider.of<SiblingsProvider>(context, listen: false);
    _casteProvider = Provider.of<CasteProvider>(context, listen: false);
    _sectProvider = Provider.of<SectProvider>(context, listen: false);
    _educationLevelProvider = Provider.of<EducationLevelProvider>(context, listen: false);
    _professionProvider = Provider.of<ProfessionProvider>(context, listen: false);

    // Set parents status
    if (widget.userProfile.isFatherAlive != null && widget.userProfile.isMotherAlive != null) {
      _parentsStatusProvider.setParentsStatus(
        fatherAlive: widget.userProfile.isFatherAlive! ? 'Yes' : 'No',
        motherAlive: widget.userProfile.isMotherAlive! ? 'Yes' : 'No',
      );
    }

    // Initialize other providers with existing data
    // (Implementation for other providers would go here)
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final profileService = Provider.of<ProfileService>(context, listen: false);

      // Get values from parents status provider
      bool? isFatherAlive = null;
      bool? isMotherAlive = null;
      if (_parentsStatusProvider.fatherAlive != null) {
        isFatherAlive = _parentsStatusProvider.fatherAlive!.option == 'Yes';
      }
      if (_parentsStatusProvider.motherAlive != null) {
        isMotherAlive = _parentsStatusProvider.motherAlive!.option == 'Yes';
      }

      // Get values from other providers
      // (Implementation for other providers would go here)

      // Create updates map with only non-null values
      Map<String, dynamic> updates = {};

      // Only add values to the map if they're not null
      if (isFatherAlive != null) {
        updates['isFatherAlive'] = isFatherAlive;
      }

      if (isMotherAlive != null) {
        updates['isMotherAlive'] = isMotherAlive;
      }

      // Add server timestamp
      updates['profileUpdatedAt'] = FieldValue.serverTimestamp();

      // Add other fields to update here

      // Update the user profile
      await profileService.updateUserProfile(updates);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully', style: TextStyle(color: whiteColor)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating profile: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage, style: TextStyle(color: whiteColor)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontSize: 24,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [pinkColor, pinkColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.pink[50]!.withOpacity(0.8),
              Colors.purple[50]!.withOpacity(0.8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Your Profile",
                style: TextStyle(
                  fontSize: headingSize * 1.3,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [pinkColor, Colors.purple[300]!],
                    ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                  shadows: [
                    Shadow(
                      blurRadius: 5,
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Update your profile information",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: subHeadingSize * 0.95,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),

              // Edit sections
              _buildEditSections(),

              const SizedBox(height: 40),
              _buildSaveButton(),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: subHeadingSize * 0.9,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditSections() {
    return Column(
      children: [
        // Personal Information Section
        _buildSectionTitle("Personal Information"),

        // Parents Status Section
        _buildParentsStatusSection(),

        // Other sections would be added here
        // _buildHeightSection(),
        // _buildMaritalStatusSection(),
        // etc.
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: headingSize,
          fontWeight: FontWeight.bold,
          color: pinkColor,
        ),
      ),
    );
  }

  Widget _buildParentsStatusSection() {
    final parentsStatusProvider = Provider.of<ParentsStatusProvider>(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95),
      margin: EdgeInsets.only(top: 10, bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.pink[50]!.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Parents Status",
              style: TextStyle(
                fontSize: subHeadingSize,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(colors: [pinkColor, Colors.purple[300]!])
                      .createShader(Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Text(
                  "Father Alive:",
                  style: TextStyle(
                    fontSize: subHeadingSize * 0.95,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  parentsStatusProvider.fatherAlive?.option ?? "Not specified",
                  style: TextStyle(
                    fontSize: subHeadingSize * 0.95,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  "Mother Alive:",
                  style: TextStyle(
                    fontSize: subHeadingSize * 0.95,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  parentsStatusProvider.motherAlive?.option ?? "Not specified",
                  style: TextStyle(
                    fontSize: subHeadingSize * 0.95,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => _showParentsStatusDialog(),
                icon: Icon(Icons.edit, size: 18, color: pinkColor),
                label: Text(
                  "Edit Details",
                  style: TextStyle(
                    color: pinkColor,
                    fontWeight: FontWeight.w600,
                    fontSize: subHeadingSize * 0.9,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: pinkColor.withOpacity(0.5), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showParentsStatusDialog() {
    final parentsStatusProvider = Provider.of<ParentsStatusProvider>(context, listen: false);
    bool fatherAlive = parentsStatusProvider.fatherAlive?.option == 'Yes';
    bool motherAlive = parentsStatusProvider.motherAlive?.option == 'Yes';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white.withOpacity(0.95),
            title: Text(
              "Parents Status",
              style: TextStyle(
                fontSize: headingSize,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(colors: [pinkColor, Colors.purple[300]!])
                      .createShader(Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Are your parents alive?",
                  style: TextStyle(color: Colors.grey[700], fontSize: subHeadingSize * 0.9),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Father"),
                        trailing: Switch(
                          value: fatherAlive,
                          onChanged: (value) {
                            setDialogState(() {
                              fatherAlive = value;
                            });
                          },
                          activeColor: pinkColor,
                          inactiveTrackColor: Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("Mother"),
                        trailing: Switch(
                          value: motherAlive,
                          onChanged: (value) {
                            setDialogState(() {
                              motherAlive = value;
                            });
                          },
                          activeColor: pinkColor,
                          inactiveTrackColor: Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pinkColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  parentsStatusProvider.setParentsStatus(
                    fatherAlive: fatherAlive ? 'Yes' : 'No',
                    motherAlive: motherAlive ? 'Yes' : 'No',
                  );
                  Navigator.pop(context);
                },
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: subHeadingSize * 0.9,
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: EdgeInsets.zero,
        ),
        onPressed: _isLoading ? null : _saveProfile,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [pinkColor, Colors.purple[300]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: pinkColor.withOpacity(0.5),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
              "Save Changes",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: headingSize * 0.95,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
