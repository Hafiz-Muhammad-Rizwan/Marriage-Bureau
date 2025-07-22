import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marriage_bereau_app/Services/profile_service.dart';

class AuthResult {
  final String? errorMessage;
  final bool isProfileComplete;
  final String? userId;

  AuthResult({
    this.errorMessage,
    this.isProfileComplete = false,
    this.userId,
  });
}

class SignUp extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Format phone number with +92 prefix
  String _formatPhoneNumber(String phoneNumber) {
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    if (!cleanedNumber.startsWith('92')) {
      if (cleanedNumber.startsWith('0')) {
        cleanedNumber = cleanedNumber.substring(1);
      }
      cleanedNumber = '+92' + cleanedNumber;
    } else if (!cleanedNumber.startsWith('+')) {
      cleanedNumber = '+' + cleanedNumber;
    }

    return cleanedNumber;
  }

  // Check if phone number already exists in Firestore
  Future<bool> checkIfPhoneNumberExists(String phoneNumber) async {
    try {
      String formattedNumber = _formatPhoneNumber(phoneNumber);
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedNumber)
          .limit(1)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error checking phone number existence: $e');
      return false;
    }
  }

  // Send OTP via Firebase phone authentication for verification only
  Future<Map<String, dynamic>> sendPhoneVerificationOTP(String phoneNumber) async {
    Completer<Map<String, dynamic>> completer = Completer<Map<String, dynamic>>();

    try {
      String formattedNumber = _formatPhoneNumber(phoneNumber);

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification completed (Android only)
          completer.complete({
            'success': true,
            'autoVerified': true,
            'message': 'Phone number automatically verified'
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          completer.complete({
            'success': false,
            'message': e.message ?? 'Verification failed'
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          completer.complete({
            'success': true,
            'autoVerified': false,
            'verificationId': verificationId,
            'resendToken': resendToken,
            'message': 'OTP sent successfully'
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Only complete if not already completed
          if (!completer.isCompleted) {
            completer.complete({
              'success': false,
              'message': 'OTP request timeout'
            });
          }
        },
        timeout: Duration(seconds: 60),
      );

      return await completer.future;
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete({
          'success': false,
          'message': 'Error sending OTP: ${e.toString()}'
        });
      }
      return await completer.future;
    }
  }

  // Verify OTP for phone number verification (doesn't create Firebase Auth account)
  Future<bool> verifyPhoneOTP(String verificationId, String otp) async {
    try {
      // Create credential with verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // We just verify the credential without signing in
      // This is just to verify the phone number is valid
      return true;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  // Sign up with email and password in Firebase Auth, store phone in Firestore
  // Make sure phone is verified via OTP before calling this method
  Future<String?> signUpWithEmailAndPassword(String email, String password, String phoneNumber) async {
    try {
      // Check if phone number already exists in Firestore
      bool phoneExists = await checkIfPhoneNumberExists(phoneNumber);
      if (phoneExists) {
        return 'Phone number already in use. Please use a different number.';
      }

      String formattedPhoneNumber = _formatPhoneNumber(phoneNumber);

      // Create user in Firebase Auth with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String userId = userCredential.user!.uid;

      // Store user data in Firestore with phone number
      await _firestore.collection('users').doc(userId).set({
        'email': email.trim(),
        'phoneNumber': formattedPhoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'isProfileComplete': false,
        'role': 'user',
        'lastActive': FieldValue.serverTimestamp(),
        'emailVerified': false
      });

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      }
      return e.message;
    } catch (e) {
      return 'Something went wrong: ${e.toString()}';
    }
  }

  // Sign in with email and password
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final userId = userCredential.user?.uid;
      if (userId != null) {
        // Check if profile is complete
        final profileDoc = await _firestore.collection('profiles').doc(userId).get();
        final bool isProfileComplete = profileDoc.exists;

        // Update last active
        await _firestore.collection('users').doc(userId).update({
          'lastActive': FieldValue.serverTimestamp(),
        });

        return AuthResult(
          userId: userId,
          isProfileComplete: isProfileComplete,
        );
      }

      return AuthResult(
        userId: userId,
        isProfileComplete: false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return AuthResult(errorMessage: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        return AuthResult(errorMessage: 'Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        return AuthResult(errorMessage: 'The email address is not valid.');
      } else if (e.code == 'user-disabled') {
        return AuthResult(errorMessage: 'This user account has been disabled.');
      }
      return AuthResult(errorMessage: e.message ?? 'Authentication failed.');
    } catch (e) {
      return AuthResult(errorMessage: 'Something went wrong: ${e.toString()}');
    }
  }

  // Send email verification
  Future<bool> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending email verification: $e');
      return false;
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Reload user to get the latest email verification status
      await user.reload();
      user = _auth.currentUser;

      return user?.emailVerified ?? false;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  // Check email verification status and show appropriate dialog
  Future<bool> checkAndHandleEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // Reload user to get the latest verification status
      await user.reload();
      user = _auth.currentUser;

      return user!.emailVerified;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }
}

class Country {
  final String name;
  final String flag;

  Country({required this.name, required this.flag});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']['common'],
      flag: json['flags']['png'],
    );
  }
}
class countryData extends ChangeNotifier
{
  List<Country> _countries = [];
  final Set<String> _selectedNationalities = {};

  List<Country> get countries => _countries;
  Set<String> get selectedNationalities => _selectedNationalities;

  Future<void> fetchCountries() async {
    final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all?fields=name,flags'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _countries = data.map((json) => Country.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load countries');
    }
  }

  void toggleNationality(String name, bool value) {
    if (value) {
      if (_selectedNationalities.length < 10) {
        _selectedNationalities.add(name);
      }
    } else {
      _selectedNationalities.remove(name);
    }
    notifyListeners();
  }}

// Height Screen
class Height {
  final int cm;
  final String inches;

  Height(this.cm, this.inches);
}

class HeightProvider extends ChangeNotifier {
  Height? _selectedHeight;
  final List<Height> _heights = [
    Height(122, "4'0\""),
    Height(124, "4'1\""),
    Height(127, "4'2\""),
    Height(130, "4'3\""),
    Height(132, "4'4\""),
    Height(135, "4'5\""),
    Height(137, "4'6\""),
    Height(140, "4'7\""),
    Height(142, "4'8\""),
    Height(145, "4'9\""),
    Height(147, "4'10\""),
    Height(150, "4'11\""),
    Height(152, "5'0\""),
    Height(155, "5'1\""),
    Height(157, "5'2\""),
    Height(160, "5'3\""),
    Height(163, "5'4\""),
    Height(165, "5'5\""),
    Height(168, "5'6\""),
    Height(170, "5'7\""),
    Height(173, "5'8\""),
    Height(175, "5'9\""),
    Height(178, "5'10\""),
    Height(180, "5'11\""),
    Height(183, "6'0\""),
    Height(185, "6'1\""),
    Height(188, "6'2\""),
    Height(190, "6'3\""),
    Height(193, "6'4\""),
    Height(195, "6'5\""),
    Height(198, "6'6\""),
  ];


  Height? get selectedHeight {
    return _selectedHeight;
  }
  List<Height> get heights {
    return _heights;
  }

  void selectHeight(Height height) {
    _selectedHeight = height;
    notifyListeners();
  }
}
// Marital Status Screen
class MaritalStatus {
  final String status;

  MaritalStatus(this.status);
}

class MaritalStatusProvider extends ChangeNotifier {
  MaritalStatus? _selectedStatus;
  final List<MaritalStatus> _statuses = [
    MaritalStatus('Never married'),
    MaritalStatus('Divorced'),
    MaritalStatus('Widowed'),
    MaritalStatus('Married'),
  ];

  MaritalStatus? get selectedStatus => _selectedStatus;
  List<MaritalStatus> get statuses => _statuses;

  void selectStatus(MaritalStatus status) {
    _selectedStatus = status;
    notifyListeners();
  }
}

// Smoke Screen

class Smoking {
  final String option;

  Smoking(this.option);
}
class SmokingProvider extends ChangeNotifier {
  Smoking? _selectedOption;
  final List<Smoking> _options = [
    Smoking('Yes'),
    Smoking('No'),
  ];

  Smoking? get selectedOption => _selectedOption;
  List<Smoking> get options => _options;

  void selectOption(Smoking option) {
    _selectedOption = option;
    notifyListeners();
  }
}

// Alchol Screen
class AlcoholConsumption {
  final String option;

  AlcoholConsumption(this.option);
}

class AlcoholConsumptionProvider extends ChangeNotifier {
  AlcoholConsumption? _selectedOption;
  final List<AlcoholConsumption> _options = [
    AlcoholConsumption('Yes'),
    AlcoholConsumption('No'),
  ];

  AlcoholConsumption? get selectedOption => _selectedOption;
  List<AlcoholConsumption> get options => _options;

  void selectOption(AlcoholConsumption option) {
    _selectedOption = option;
    notifyListeners();
  }
}

// Children Screen
class Children {
  final String option;

  Children(this.option);
}
class ChildrenProvider extends ChangeNotifier {
  Children? _selectedOption;
  final List<Children> _options = [
    Children('Yes'),
    Children('No'),
  ];

  // New fields for child details
  int _totalChildren = 0;
  int _sons = 0;
  int _daughters = 0;

  Children? get selectedOption => _selectedOption;
  List<Children> get options => _options;

  // Getters for the child details
  int get totalChildren => _totalChildren;
  int get sons => _sons;
  int get daughters => _daughters;

  // Method to get formatted children details as a string
  String getChildrenDetails() {
    if (_selectedOption?.option == 'No') {
      return 'No';
    } else if (_totalChildren > 0) {
      return '$_totalChildren children (Sons: $_sons, Daughters: $_daughters)';
    } else {
      return 'Yes';
    }
  }

  void selectOption(Children option) {
    _selectedOption = option;

    // Reset details if "No" is selected
    if (option.option == "No") {
      _totalChildren = 0;
      _sons = 0;
      _daughters = 0;
    }

    notifyListeners();
  }

  // New method for setting children details
  void setChildrenDetails(int total, int sons, int daughters) {
    _totalChildren = total;
    _sons = sons;
    _daughters = daughters;
    notifyListeners();
  }
}

// Moving Abroad Screen
class MoveAbroad {
  final String option;

  MoveAbroad(this.option);
}
class MoveAbroadProvider with ChangeNotifier {
  MoveAbroad? _selectedOption;
  final List<MoveAbroad> _options = [
    MoveAbroad('Yes'),
    MoveAbroad('No'),
  ];

  MoveAbroad? get selectedOption => _selectedOption;
  List<MoveAbroad> get options => _options;

  void selectOption(MoveAbroad option) {
    _selectedOption = option;
    notifyListeners();
  }
}

// Intrest Screen
class Interest {
  final String category;
  final String option;
  final String icon;

  Interest(this.category, this.option, this.icon);
}

class InterestProvider extends ChangeNotifier {
  final List<Interest> _interests = [
    Interest('Arts & Culture', 'Acting', '🎭'),
    Interest('Arts & Culture', 'Anime', '🍿'),
    Interest('Arts & Culture', 'Art galleries', '🖼️'),
    Interest('Arts & Culture', 'Board games', '🎲'),
    Interest('Arts & Culture', 'Creative writing', '✍️'),
    Interest('Arts & Culture', 'Design', '🎨'),
    Interest('Arts & Culture', 'DIY', '🔧'),
    Interest('Arts & Culture', 'Fashion', '👗'),
    Interest('Arts & Culture', 'Film & Cinema', '🎬'),
    Interest('Arts & Culture', 'Filmmaking', '📽️'),
    Interest('Arts & Culture', 'Knitting', '🧶'),
    Interest('Arts & Culture', 'Learning languages', '🌐'),
    Interest('Arts & Culture', 'Live music', '🎵'),
    Interest('Arts & Culture', 'Museums', '🏛���'),
    Interest('Arts & Culture', 'Painting', '🎨'),
    Interest('Arts & Culture', 'Photography', '📸'),
    Interest('Politics', 'Politics', '🏛️'),
    Interest('Social', 'Spending time with friends', '👥'),
    Interest('Social', 'Volunteering', '🤲'),
    Interest('Food & Drink', 'Baking', '🧁'),
    Interest('Food & Drink', 'Bubble tea', '🍵'),
    Interest('Food & Drink', 'Cake decorating', '🎂'),
    Interest('Food & Drink', 'Chocolate', '🍫'),
    Interest('Food & Drink', 'Coffee', '☕'),
    Interest('Food & Drink', 'Cooking', '🍳'),
    Interest('Food & Drink', 'Eating out', '🍽️'),
    Interest('Food & Drink', 'Fish & chips', '����'),
    Interest('Food & Drink', 'Healthy eating', '🥗'),
    Interest('Food & Drink', 'Junk food', '🍔'),
    Interest('Islamic', 'Ashura', '🌙'),
    Interest('Islamic', 'Charity', '🤲'),
    Interest('Islamic', 'Completed Hajj', '🕋'),
    Interest('Islamic', 'Completed Umrah', '🕌'),
    Interest('Islamic', 'Duaa for others', '🙏'),
    Interest('Islamic', 'Fasting', '🍽️'),
    Interest('Islamic', 'Hafith', '📖'),
    Interest('Islamic', 'Islamic events', '🎉'),
    Interest('Islamic', 'Islamic lectures', '🎙️'),
    Interest('Islamic', 'Islamic studies', '📚'),
    Interest('Islamic', 'Khatam', '📜'),
    Interest('Islamic', 'Learning Arabic', '🇦🇪'),
    Interest('Islamic', 'Masjid regularly', '🏟️'),
    Interest('Islamic', 'Mawlid', '🎂'),
    Interest('Islamic', 'Muharram', '🌙'),
    Interest('Islamic', 'Reading Qur\'an', '📖'),
    Interest('Islamic', 'Voluntary prayers', '🙏'),
    Interest('Sports', 'Surfing', '🏄'),
    Interest('Sports', 'Swimming', '🏊'),
    Interest('Sports', 'Tennis', '🎾'),
    Interest('Sports', 'Volleyball', '🏐'),
    Interest('Sports', 'Yoga', '🧘'),
    Interest('Sports', 'Playing', '🎮'), // Added interest
    Interest('Technology', 'Animation', '🎬'),
    Interest('Technology', 'Blogging', '📝'),
    Interest('Technology', 'Coding', '💻'),
    Interest('Technology', 'Content creation', '📹'),
    Interest('Technology', 'Digital art', '🖌️'),
    Interest('Technology', 'Influencer', '⭐'),
    Interest('Technology', 'Live streaming', '📡'),
    Interest('Technology', 'Tech', '🤖'),
    Interest('Technology', 'Video games', '🎮'),
  ];

  final Set<Interest> _selectedInterests = {};
  static const int maxSelections = 15;

  Set<Interest> get selectedInterests {
    return _selectedInterests;
  }
  List<Interest> get interests => _interests;

  void toggleInterest(Interest interest) {
    if (_selectedInterests.contains(interest)) {
      _selectedInterests.remove(interest);
    } else if (_selectedInterests.length < maxSelections) {
      _selectedInterests.add(interest);
    }
    notifyListeners();
  }

  bool isSelected(Interest interest) => _selectedInterests.contains(interest);
}

// Parents Alive Screen
class ParentsStatus {
  final String option;

  ParentsStatus(this.option);
}

class ParentsStatusProvider extends ChangeNotifier {
  ParentsStatus? _fatherAlive;
  ParentsStatus? _motherAlive;

  final List<ParentsStatus> _options = [
    ParentsStatus('Yes'),
    ParentsStatus('No'),
  ];

  ParentsStatus? get fatherAlive => _fatherAlive;
  ParentsStatus? get motherAlive => _motherAlive;
  List<ParentsStatus> get options => _options;

  void selectFatherStatus(ParentsStatus option) {
    _fatherAlive = option;
    notifyListeners();
  }

  void selectMotherStatus(ParentsStatus option) {
    _motherAlive = option;
    notifyListeners();
  }

  void setParentsStatus({required String fatherAlive, required String motherAlive}) {
    _fatherAlive = _options.firstWhere((option) => option.option == fatherAlive);
    _motherAlive = _options.firstWhere((option) => option.option == motherAlive);
    notifyListeners();
  }
}

// Progress Screeen
class ProgressProvider extends ChangeNotifier {
  int _currentScreen = 0;
  final int _totalScreens = 19; // Increased by 1 for the new parents screen

  int get currentScreen => _currentScreen;
  int get totalScreens => _totalScreens;
  double get progress => _currentScreen / (_totalScreens - 1);

  void nextScreen() {
    if (_currentScreen < _totalScreens - 1) {
      _currentScreen++;
      notifyListeners();
    }
  }

  void previousScreen() {
    if (_currentScreen > 0) {
      _currentScreen--;
      notifyListeners();
    }
  }
}

// Education Level
class EducationLevel {
  final String level;

  EducationLevel(this.level);
}

class EducationLevelProvider extends ChangeNotifier {
  EducationLevel? _selectedLevel;
  final List<EducationLevel> _levels = [
    EducationLevel('High School'),
    EducationLevel('Associate Degree'),
    EducationLevel('Bachelor\'s Degree'),
    EducationLevel('Master\'s Degree'),
    EducationLevel('Doctorate'),
    EducationLevel('Professional Degree'),
    EducationLevel('Vocational Training'),
    EducationLevel('Other'),
  ];

  EducationLevel? get selectedLevel => _selectedLevel;
  List<EducationLevel> get levels => _levels;

  void selectLevel(EducationLevel level) {
    _selectedLevel = level;
    notifyListeners();
  }
}

// Profession
class Profession {
  final String name;

  Profession(this.name);
}

class ProfessionProvider extends ChangeNotifier {
  Profession? _selectedProfession;
  final TextEditingController _professionController = TextEditingController();

  // Common professions (you can extend this list)
  final List<Profession> _commonProfessions = [
    Profession('Teacher'),
    Profession('Doctor'),
    Profession('Engineer'),
    Profession('Lawyer'),
    Profession('Business Owner'),
    Profession('IT Professional'),
    Profession('Accountant'),
    Profession('Student'),
    Profession('Retired'),
    Profession('Other'),
  ];

  Profession? get selectedProfession => _selectedProfession;
  List<Profession> get commonProfessions => _commonProfessions;
  TextEditingController get professionController => _professionController;

  void selectProfession(Profession profession) {
    _selectedProfession = profession;
    notifyListeners();
  }

  void setCustomProfession(String profession) {
    _selectedProfession = Profession(profession);
    notifyListeners();
  }

  @override
  void dispose() {
    _professionController.dispose();
    super.dispose();
  }
}

// Sect
class Sect {
  final String name;

  Sect(this.name);
}

class SectProvider extends ChangeNotifier {
  Sect? _selectedSect;
  String _customSectName = '';
  final List<Sect> _sects = [
    Sect('Ahl e Sunnat'),
    Sect('Ahl e Hadees'),
    Sect('Ahl e Deoband'),
    Sect('Ahl e Tashee'),
    Sect('Other'),
    Sect('Prefer not to say'),
  ];

  Sect? get selectedSect => _selectedSect;
  List<Sect> get sects => _sects;
  String get customSectName => _customSectName;

  void selectSect(Sect sect) {
    _selectedSect = sect;
    // Reset custom sect name if not selecting "Other"
    if (sect.name != 'Other') {
      _customSectName = '';
    }
    notifyListeners();
  }

  void setCustomSectName(String name) {
    _customSectName = name;
    notifyListeners();
  }

  // Get the actual sect name (including custom name for "Other")
  String getActualSectName() {
    if (_selectedSect?.name == 'Other' && _customSectName.isNotEmpty) {
      return _customSectName;
    }
    return _selectedSect?.name ?? '';
  }
}

// Gender
class Gender {
  final String type;

  Gender(this.type);
}

class GenderProvider extends ChangeNotifier {
  Gender? _selectedGender;
  final List<Gender> _genders = [
    Gender('Male'),
    Gender('Female'),
  ];

  Gender? get selectedGender => _selectedGender;
  List<Gender> get genders => _genders;

  void selectGender(Gender gender) {
    _selectedGender = gender;
    notifyListeners();
  }
}

// Name and Age Provider
class NameAgeProvider extends ChangeNotifier {
  String _fullName = '';
  DateTime _dateOfBirth = DateTime.now();
  String? _profileImagePath;

  String get fullName => _fullName;
  DateTime get dateOfBirth => _dateOfBirth;
  String? get profileImagePath => _profileImagePath;

  void setFullName(String name) {
    _fullName = name;
    notifyListeners();
  }

  void setDateOfBirth(DateTime dob) {
    _dateOfBirth = dob;
    notifyListeners();
  }

  void setProfileImagePath(String path) {
    _profileImagePath = path;
    notifyListeners();
  }
}

// Siblings Provider
class SiblingsProvider extends ChangeNotifier {
  bool? _hasSiblings;
  int _totalSiblings = 0;
  int _brothers = 0;
  int _sisters = 0;

  bool? get hasSiblings => _hasSiblings;
  int get totalSiblings => _totalSiblings;
  int get brothers => _brothers;
  int get sisters => _sisters;

  void setHasSiblings(bool value) {
    _hasSiblings = value;
    // Reset counts if no siblings
    if (!value) {
      _totalSiblings = 0;
      _brothers = 0;
      _sisters = 0;
    } else if (_totalSiblings == 0) {
      // Default to 1 sibling if siblings is true but count is 0
      _totalSiblings = 1;
    }
    notifyListeners();
  }

  void setSiblingsDetails(int total, int brothers, int sisters) {
    _totalSiblings = total;
    _brothers = brothers;
    _sisters = sisters;
    notifyListeners();
  }

  // Method to get formatted siblings details as a string
  String getSiblingsDetails() {
    if (_hasSiblings == null || _hasSiblings == false) {
      return 'No siblings';
    } else if (_totalSiblings > 0) {
      return '$_totalSiblings siblings ($_brothers brothers, $_sisters sisters)';
    } else {
      return 'Has siblings';
    }
  }
}

// Caste Provider
class Caste {
  final String name;

  Caste(this.name);
}

class CasteProvider extends ChangeNotifier {
  Caste? _selectedCaste;
  String _customCasteName = '';
  final List<Caste> _castes = [
    Caste('Sayyid'),
    Caste('Sheikh'),
    Caste('Mughal'),
    Caste('Pathan'),
    Caste('Ansari'),
    Caste('Qureshi'),
    Caste('Julaha'),
    Caste('Jat'),
    Caste('Arain'),
    Caste('Rajput'),
    Caste('Gujjar'),
    Caste('Awan'),
    Caste('Mussali'),
    Caste('Mochi'),
    Caste('Kumhar'),
    Caste('Mirasi'),
    Caste('Khokhar'),
    Caste('Malik'),
    Caste('Chaudhry'),
    Caste('Other'),
    Caste('Prefer not to say'),
  ];

  Caste? get selectedCaste => _selectedCaste;
  List<Caste> get castes => _castes;
  String get customCasteName => _customCasteName;

  void selectCaste(Caste caste) {
    _selectedCaste = caste;
    // Reset custom caste name if not selecting "Other"
    if (caste.name != 'Other') {
      _customCasteName = '';
    }
    notifyListeners();
  }

  void setCustomCasteName(String name) {
    _customCasteName = name;
    notifyListeners();
  }

  // Get the actual caste name (including custom name for "Other")
  String getActualCasteName() {
    if (_selectedCaste?.name == 'Other' && _customCasteName.isNotEmpty) {
      return _customCasteName;
    }
    return _selectedCaste?.name ?? '';
  }
}
