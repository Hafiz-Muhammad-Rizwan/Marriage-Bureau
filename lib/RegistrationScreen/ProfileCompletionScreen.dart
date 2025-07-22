import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marriage_bereau_app/Backend%20Logic/Sign%20Up%20Logic.dart';
import 'package:marriage_bereau_app/Essentials/colors.dart';
import 'package:marriage_bereau_app/Essentials/fontSizes.dart';
import 'package:marriage_bereau_app/Models/user_profile_model.dart';
import 'package:marriage_bereau_app/Screens/homeScreen.dart';
import 'package:marriage_bereau_app/Services/profile_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final String? imagePath;
  final String fullName;
  final DateTime dateOfBirth;


  const ProfileCompletionScreen({
    Key? key,
    this.imagePath,
    required this.fullName,
    required this.dateOfBirth,
  }) : super(key: key);

  @override
  _ProfileCompletionScreenState createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _saveUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final heightProvider = Provider.of<HeightProvider>(context, listen: false);
      final maritalStatusProvider = Provider.of<MaritalStatusProvider>(context, listen: false);
      final smokingProvider = Provider.of<SmokingProvider>(context, listen: false);
      final alcoholProvider = Provider.of<AlcoholConsumptionProvider>(context, listen: false);
      final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
      final moveAbroadProvider = Provider.of<MoveAbroadProvider>(context, listen: false);
      final interestProvider = Provider.of<InterestProvider>(context, listen: false);
      final countryDataProvider = Provider.of<countryData>(context, listen: false);
      final genderProvider = Provider.of<GenderProvider>(context, listen: false);
      final educationLevelProvider = Provider.of<EducationLevelProvider>(context, listen: false);
      final professionProvider = Provider.of<ProfessionProvider>(context, listen: false);
      final sectProvider = Provider.of<SectProvider>(context, listen: false);
      final siblingsProvider = Provider.of<SiblingsProvider>(context, listen: false);
      final casteProvider = Provider.of<CasteProvider>(context, listen: false); // Added caste provider
      final parentsStatusProvider = Provider.of<ParentsStatusProvider>(context, listen: false); // Added parents status provider
      final homeDetailProvider=Provider.of<HomeProvider>(context,listen: false);
      final guardianProvider=Provider.of<GuardianLevelProvider>(context,listen: false);

      // Validate children count
      if (childrenProvider.selectedOption?.option == 'Yes' &&
          childrenProvider.sons + childrenProvider.daughters != childrenProvider.totalChildren) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'The sum of boys and girls must equal the total number of children!';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage, style: TextStyle(color: whiteColor)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Validate siblings count
      if (siblingsProvider.hasSiblings == true &&
          siblingsProvider.brothers + siblingsProvider.sisters != siblingsProvider.totalSiblings) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'The sum of brothers and sisters must equal the total number of siblings!';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage, style: TextStyle(color: whiteColor)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final height = heightProvider.selectedHeight?.inches;
      final maritalStatus = maritalStatusProvider.selectedStatus?.status;
      final smoking = smokingProvider.selectedOption?.option;
      final alcohol = alcoholProvider.selectedOption?.option;
      final children = childrenProvider.selectedOption?.option;
      final moveAbroad = moveAbroadProvider.selectedOption?.option;
      final caste = casteProvider.selectedCaste?.name; // Get selected caste
      final guardian=guardianProvider.selectedLevel?.level;
      final homeAddress=homeDetailProvider.address;
      final homeType=homeDetailProvider.selectedHome;
      final homeCity=homeDetailProvider.city;
      final country=homeDetailProvider.country;
      final guardianNumber=guardianProvider.selectedLevel?.number;

      // Convert ParentsStatus to boolean values
      bool? isFatherAlive = null;
      bool? isMotherAlive = null;
      if (parentsStatusProvider.fatherAlive != null) {
        isFatherAlive = parentsStatusProvider.fatherAlive!.option == 'Yes';
      }
      if (parentsStatusProvider.motherAlive != null) {
        isMotherAlive = parentsStatusProvider.motherAlive!.option == 'Yes';
      }

      String? boysCount = null;
      String? girlsCount = null;
      if (children == 'Yes') {
        boysCount = childrenProvider.sons > 0 ? childrenProvider.sons.toString() : null;
        girlsCount = childrenProvider.daughters > 0 ? childrenProvider.daughters.toString() : null;
      }

      final educationLevel = educationLevelProvider.selectedLevel?.level;
      final profession = professionProvider.selectedProfession?.name;
      final sect = sectProvider.selectedSect?.name;

      final List<String> interests = interestProvider.selectedInterests
          .map((interest) => interest.option)
          .toList();

      final List<String> nationalities = countryDataProvider.selectedNationalities.toList();

      final now = DateTime.now();
      final age = now.year - widget.dateOfBirth.year -
          (now.month < widget.dateOfBirth.month ||
              (now.month == widget.dateOfBirth.month && now.day < widget.dateOfBirth.day)
              ? 1
              : 0);

      final profileService = Provider.of<ProfileService>(context, listen: false);

      await profileService.createUserProfile(
        fullName: widget.fullName,
        dateOfBirth: widget.dateOfBirth,
        age: age,
        gender: genderProvider.selectedGender?.type ?? "Not specified",
        profileImagePath: widget.imagePath,
        height: height,
        maritalStatus: maritalStatus,
        smoking: smoking,
        alcohol: alcohol,
        children: children,
        boysCount: boysCount,
        girlsCount: girlsCount,
        moveAbroad: moveAbroad,
        interests: interests,
        nationalities: nationalities,
        educationLevel: educationLevel,
        profession: profession,
        sect: sect,
        hasSiblings: siblingsProvider.hasSiblings,
        totalSiblings: siblingsProvider.totalSiblings,
        brothers: siblingsProvider.brothers,
        sisters: siblingsProvider.sisters,
        caste: caste, // Include caste in profile data
        isFatherAlive: isFatherAlive, // Include father's status
        isMotherAlive: isMotherAlive, // Include mother's status
        guardianType: guardian,
        guardianNumber: guardianNumber,
        city: homeCity,
        country: country,
        homeType: homeType,
        address: homeAddress
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving profile: ${e.toString()}';
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
          "Profile Summary",
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "You're Almost There!",
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
                "Review your profile details to complete registration",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: subHeadingSize * 0.95,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 30),
              _buildProfileImage(),
              const SizedBox(height: 20),
              Text(
                widget.fullName,
                style: TextStyle(
                  fontSize: headingSize * 1.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                "Born: ${DateFormat('MMMM d, y').format(widget.dateOfBirth)}",
                style: TextStyle(
                  fontSize: subHeadingSize * 0.95,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),
              _buildProfileSummary(),
              if (Provider.of<ParentsStatusProvider>(context).fatherAlive != null ||
                  Provider.of<ParentsStatusProvider>(context).motherAlive != null)
                _buildParentsStatusSection(),
              if (Provider.of<ChildrenProvider>(context).selectedOption?.option == 'Yes')
                _buildChildrenDetailsSection(),
              if (Provider.of<SiblingsProvider>(context).hasSiblings != null)
                _buildSiblingsDetailsSection(),
              const SizedBox(height: 40),
              _buildCompleteButton(),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Hero(
      tag: 'profile-image',
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [pinkColor.withOpacity(0.3), Colors.purple[200]!.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: ClipOval(
          child: widget.imagePath != null
              ? Image.file(
            File(widget.imagePath!),
            fit: BoxFit.cover,
            width: 140,
            height: 140,
          )
              : Container(
            color: Colors.grey[300],
            child: Icon(
              Icons.person,
              size: 70,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSummary() {
    final heightProvider = Provider.of<HeightProvider>(context);
    final maritalStatusProvider = Provider.of<MaritalStatusProvider>(context);
    final smokingProvider = Provider.of<SmokingProvider>(context);
    final alcoholProvider = Provider.of<AlcoholConsumptionProvider>(context);
    final childrenProvider = Provider.of<ChildrenProvider>(context);
    final moveAbroadProvider = Provider.of<MoveAbroadProvider>(context);
    final interestProvider = Provider.of<InterestProvider>(context);
    final countryDataProvider = Provider.of<countryData>(context);
    final siblingsProvider = Provider.of<SiblingsProvider>(context);
    final casteProvider = Provider.of<CasteProvider>(context); // Added caste provider
    final parentsStatusProvider = Provider.of<ParentsStatusProvider>(context); // Added parents status provider
    final homeDetailProvider=Provider.of<HomeProvider>(context,listen: false);
    final guardianProvider=Provider.of<GuardianLevelProvider>(context,listen: false);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95),
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
            _buildSummaryItem("Height", heightProvider.selectedHeight?.inches ?? "Not specified"),
            _buildSummaryItem("Marital Status", maritalStatusProvider.selectedStatus?.status ?? "Not specified"),
            _buildSummaryItem("Smoking", smokingProvider.selectedOption?.option ?? "Not specified"),
            _buildSummaryItem("Alcohol", alcoholProvider.selectedOption?.option ?? "Not specified"),
            _buildSummaryItem("Has Children", childrenProvider.selectedOption?.option ?? "Not specified"),
            _buildSummaryItem("Has Siblings", siblingsProvider.hasSiblings == true ? "Yes" : (siblingsProvider.hasSiblings == false ? "No" : "Not specified")),
            _buildSummaryItem("Father Alive", parentsStatusProvider.fatherAlive?.option ?? "Not specified"),
            _buildSummaryItem("Mother Alive", parentsStatusProvider.motherAlive?.option ?? "Not specified"),
            _buildSummaryItem("Would Move Abroad", moveAbroadProvider.selectedOption?.option ?? "Not specified"),
            _buildSummaryItem("Caste", casteProvider.selectedCaste?.name ?? "Not specified"), // Added caste summary item
            _buildSummaryItem("Guardian", guardianProvider.selectedLevel?.level ?? "Not specified"),
            _buildSummaryItem("Guardian Number", guardianProvider.selectedLevel?.number ?? "Not specified"),
            _buildSummaryItem("Address", homeDetailProvider.address ?? "Not specified"),
            _buildSummaryItem("City", homeDetailProvider.city ?? "Not specified"),
            _buildSummaryItem("Country", homeDetailProvider.country ?? "Not specified"),
            _buildSummaryItem("Home Type", homeDetailProvider.selectedHome ?? "Not specified"),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: subHeadingSize * 0.95,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: subHeadingSize * 0.95,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenDetailsSection() {
    final childrenProvider = Provider.of<ChildrenProvider>(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95),
      margin: EdgeInsets.only(top: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.purple[50]!.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Children Details",
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
                  "Number of children:",
                  style: TextStyle(
                    fontSize: subHeadingSize * 0.95,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "${childrenProvider.totalChildren}",
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
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "Boys:",
                        style: TextStyle(
                          fontSize: subHeadingSize * 0.95,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${childrenProvider.sons}",
                        style: TextStyle(
                          fontSize: subHeadingSize * 0.95,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "Girls:",
                        style: TextStyle(
                          fontSize: subHeadingSize * 0.95,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${childrenProvider.daughters}",
                        style: TextStyle(
                          fontSize: subHeadingSize * 0.95,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => _showChildrenDetailsDialog(),
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

  Widget _buildSiblingsDetailsSection() {
    final siblingsProvider = Provider.of<SiblingsProvider>(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95),
      margin: EdgeInsets.only(top: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.purple[50]!.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Siblings Details",
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
                  "Number of siblings:",
                  style: TextStyle(
                    fontSize: subHeadingSize * 0.95,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "${siblingsProvider.totalSiblings}",
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
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "Brothers:",
                        style: TextStyle(
                          fontSize: subHeadingSize * 0.95,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${siblingsProvider.brothers}",
                        style: TextStyle(
                          fontSize: subHeadingSize * 0.95,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "Sisters:",
                        style: TextStyle(
                          fontSize: subHeadingSize * 0.95,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${siblingsProvider.sisters}",
                        style: TextStyle(
                          fontSize: subHeadingSize * 0.95,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => _showSiblingsDetailsDialog(),
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

  void _showChildrenDetailsDialog() {
    final childrenProvider = Provider.of<ChildrenProvider>(context, listen: false);
    int boys = childrenProvider.sons;
    int girls = childrenProvider.daughters;
    int totalChildren = childrenProvider.totalChildren;

    // If total is 0, initialize it as the sum of boys and girls
    if (totalChildren == 0) {
      totalChildren = boys + girls;
      if (totalChildren == 0) totalChildren = 1; // Default to at least 1
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white.withOpacity(0.95),
            title: Text(
              "Children Details",
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
                  "Provide details about your children",
                  style: TextStyle(color: Colors.grey[700], fontSize: subHeadingSize * 0.9),
                ),
                const SizedBox(height: 20),
                // Total children section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Children",
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: pinkColor.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [Colors.white, pinkColor.withOpacity(0.1)],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, size: 20, color: pinkColor),
                            onPressed: totalChildren > 1
                                ? () {
                                    setDialogState(() {
                                      totalChildren--;
                                      // If reducing total makes it less than current boys+girls
                                      if (boys + girls > totalChildren) {
                                        // First reduce girls, then boys if needed
                                        if (girls > 0) {
                                          girls--;
                                        } else if (boys > 0) {
                                          boys--;
                                        }
                                      }
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            "$totalChildren",
                            style: TextStyle(fontSize: subHeadingSize, color: Colors.black87),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, size: 20, color: pinkColor),
                            onPressed: () {
                              setDialogState(() => totalChildren++);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Number of Boys",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: pinkColor.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [Colors.white, pinkColor.withOpacity(0.1)],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove, size: 20, color: pinkColor),
                                  onPressed: boys > 0
                                      ? () {
                                          setDialogState(() => boys--);
                                        }
                                      : null,
                                ),
                                Text(
                                  "$boys",
                                  style: TextStyle(fontSize: subHeadingSize, color: Colors.black87),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add, size: 20, color: pinkColor),
                                  // Only allow adding if boys+girls < totalChildren
                                  onPressed: boys + girls < totalChildren
                                      ? () {
                                          setDialogState(() => boys++);
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Number of Girls",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: pinkColor.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [Colors.white, pinkColor.withOpacity(0.1)],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove, size: 20, color: pinkColor),
                                  onPressed: girls > 0
                                      ? () {
                                          setDialogState(() => girls--);
                                        }
                                      : null,
                                ),
                                Text(
                                  "$girls",
                                  style: TextStyle(fontSize: subHeadingSize, color: Colors.black87),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add, size: 20, color: pinkColor),
                                  // Only allow adding if boys+girls < totalChildren
                                  onPressed: boys + girls < totalChildren
                                      ? () {
                                          setDialogState(() => girls++);
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Show warning message if counts don't match
                if (boys + girls != totalChildren)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      "The sum of boys and girls should equal the total number of children.",
                      style: TextStyle(color: Colors.redAccent, fontSize: subHeadingSize * 0.85),
                    ),
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
                // Disable save button if counts don't match
                onPressed: (boys + girls == totalChildren)
                    ? () {
                        childrenProvider.setChildrenDetails(totalChildren, boys, girls);
                        Navigator.pop(context);
                      }
                    : null,
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

  void _showSiblingsDetailsDialog() {
    final siblingsProvider = Provider.of<SiblingsProvider>(context, listen: false);
    int brothers = siblingsProvider.brothers;
    int sisters = siblingsProvider.sisters;
    int totalSiblings = siblingsProvider.totalSiblings;

    // Initialize total siblings if needed
    if (totalSiblings == 0) {
      totalSiblings = brothers + sisters;
      if (totalSiblings == 0) totalSiblings = 1; // Default to at least 1
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white.withOpacity(0.95),
            title: Text(
              "Siblings Details",
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
                  "Provide details about your siblings",
                  style: TextStyle(color: Colors.grey[700], fontSize: subHeadingSize * 0.9),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Siblings",
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: pinkColor.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [Colors.white, pinkColor.withOpacity(0.1)],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, size: 20, color: pinkColor),
                            onPressed: totalSiblings > 1
                                ? () {
                                    setDialogState(() {
                                      totalSiblings--;
                                      // If reducing total makes it less than current brothers+sisters
                                      if (brothers + sisters > totalSiblings) {
                                        // First reduce sisters, then brothers if needed
                                        if (sisters > 0) {
                                          sisters--;
                                        } else if (brothers > 0) {
                                          brothers--;
                                        }
                                      }
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            "$totalSiblings",
                            style: TextStyle(fontSize: subHeadingSize, color: Colors.black87),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, size: 20, color: pinkColor),
                            onPressed: () {
                              setDialogState(() => totalSiblings++);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Brothers",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: pinkColor.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [Colors.white, pinkColor.withOpacity(0.1)],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove, size: 20, color: pinkColor),
                                  onPressed: brothers > 0
                                      ? () {
                                setDialogState(() => brothers--);
                              }
                                      : null,
                                ),
                                Text(
                                  "$brothers",
                                  style: TextStyle(fontSize: subHeadingSize, color: Colors.black87),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add, size: 20, color: pinkColor),
                                  onPressed: brothers + sisters < totalSiblings
                                      ? () {
                                setDialogState(() => brothers++);
                              }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sisters",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: pinkColor.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [Colors.white, pinkColor.withOpacity(0.1)],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove, size: 20, color: pinkColor),
                                  onPressed: sisters > 0
                                      ? () {
                                setDialogState(() => sisters--);
                              }
                                      : null,
                                ),
                                Text(
                                  "$sisters",
                                  style: TextStyle(fontSize: subHeadingSize, color: Colors.black87),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add, size: 20, color: pinkColor),
                                  onPressed: brothers + sisters < totalSiblings
                                      ? () {
                                setDialogState(() => sisters++);
                              }
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (brothers + sisters != totalSiblings)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      "The sum of brothers and sisters should equal the total number of siblings.",
                      style: TextStyle(color: Colors.redAccent, fontSize: subHeadingSize * 0.85),
                    ),
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
                onPressed: brothers + sisters == totalSiblings
                    ? () {
              siblingsProvider.setSiblingsDetails(totalSiblings, brothers, sisters);
              Navigator.pop(context);
            }
                    : null,
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

  Widget _buildCompleteButton() {
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
        onPressed: _isLoading ? null : _saveUserProfile,
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
              "Complete Registration",
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

  Widget _buildParentsStatusSection() {
    final parentsStatusProvider = Provider.of<ParentsStatusProvider>(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.95),
      margin: EdgeInsets.only(top: 20),
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
}
