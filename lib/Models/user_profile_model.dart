import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String userId;
  final String fullName;
  final Timestamp dateOfBirth;
  final int age;
  final String gender;
  final String? profileImage;
  final String? educationLevel;
  final String? profession;
  final String? sect;
  final String? caste; // Added caste field
  final String? smoking;
  final String? alcohol;
  final String? children;
  final String? boysCount;  // Added field for number of boys
  final String? girlsCount; // Added field for number of girls
  final String? height;
  final String? maritalStatus;
  final String? moveAbroad;
  final List<String>? interests;
  final List<String>? nationalities;
  final Timestamp profileCreatedAt;
  final Timestamp profileUpdatedAt;
  final bool isVisible;
  final bool isVerified;
  final bool? hasSiblings;     // Added field for has siblings
  final int? totalSiblings;    // Added field for total siblings
  final int? brothers;         // Added field for brothers count
  final int? sisters;          // Added field for sisters count
  final bool? isFatherAlive;   // Added field for father alive status
  final bool? isMotherAlive;   // Added field for mother alive status

  UserProfile({
    required this.userId,
    required this.fullName,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    this.profileImage,
    this.educationLevel,
    this.profession,
    this.sect,
    this.caste, // Added parameter for caste
    this.smoking,
    this.alcohol,
    this.children,
    this.boysCount,
    this.girlsCount,
    this.height,
    this.maritalStatus,
    this.moveAbroad,
    this.interests,
    this.nationalities,
    required this.profileCreatedAt,
    required this.profileUpdatedAt,
    this.isVisible = true,
    this.isVerified = false,
    this.hasSiblings,
    this.totalSiblings,
    this.brothers,
    this.sisters,
    this.isFatherAlive,
    this.isMotherAlive,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserProfile(
      userId: doc.id,
      fullName: data['fullName'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? Timestamp.now(),
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      profileImage: data['profileImage'],
      educationLevel: data['educationLevel'],
      profession: data['profession'],
      sect: data['sect'],
      caste: data['caste'], // Added caste field
      smoking: data['smoking'],
      alcohol: data['alcohol'],
      children: data['children'],
      boysCount: data['boysCount'],
      girlsCount: data['girlsCount'],
      height: data['height'],
      maritalStatus: data['maritalStatus'],
      moveAbroad: data['moveAbroad'],
      interests: data['interests'] != null ? List<String>.from(data['interests']) : null,
      nationalities: data['nationalities'] != null ? List<String>.from(data['nationalities']) : null,
      profileCreatedAt: data['profileCreatedAt'] ?? Timestamp.now(),
      profileUpdatedAt: data['profileUpdatedAt'] ?? Timestamp.now(),
      isVisible: data['isVisible'] ?? true,
      isVerified: data['isVerified'] ?? false,
      hasSiblings: data['hasSiblings'],
      totalSiblings: data['totalSiblings'],
      brothers: data['brothers'],
      sisters: data['sisters'],
      isFatherAlive: data['isFatherAlive'],
      isMotherAlive: data['isMotherAlive'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'gender': gender,
      'profileImage': profileImage,
      'educationLevel': educationLevel,
      'profession': profession,
      'sect': sect,
      'caste': caste, // Added caste field to map
      'smoking': smoking != null ? smoking : null,
      'alcohol': alcohol != null ? alcohol : null,
      'children': children != null ? children : null,
      'boysCount': boysCount != null ? boysCount : null,
      'girlsCount': girlsCount != null ? girlsCount : null,
      'height': height != null ? height : null,
      'maritalStatus': maritalStatus != null ? maritalStatus : null,
      'moveAbroad': moveAbroad != null ? moveAbroad : null,
      'interests': interests,
      'nationalities': nationalities,
      'profileCreatedAt': profileCreatedAt,
      'profileUpdatedAt': profileUpdatedAt,
      'isVisible': isVisible,
      'isVerified': isVerified,
      'hasSiblings': hasSiblings,
      'totalSiblings': totalSiblings,
      'brothers': brothers,
      'sisters': sisters,
      'isFatherAlive': isFatherAlive,
      'isMotherAlive': isMotherAlive,
    };
  }
}
