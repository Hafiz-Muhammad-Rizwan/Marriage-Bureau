import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../Models/user_profile_model.dart';

class ProfileService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Current user profile data
  UserProfile? _currentUserProfile;
  bool _isLoading = false;

  UserProfile? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;

  // Create a new user profile
  Future<void> createUserProfile({
    required String fullName,
    required DateTime dateOfBirth,
    required int age,
    required String gender,
    String? profileImagePath,
    String? educationLevel,
    String? profession,
    String? sect,
    String? caste, // Added caste parameter
    String? smoking,
    String? alcohol,
    String? children,
    String? boysCount,
    String? girlsCount,
    String? height,
    String? maritalStatus,
    String? moveAbroad,
    List<String>? interests,
    List<String>? nationalities,
    bool? hasSiblings,
    int? totalSiblings,
    int? brothers,
    int? sisters,
    bool? isFatherAlive, // Added parameter for father status
    bool? isMotherAlive, // Added parameter for mother status
    String? address,
    String? homeType,
    String? city,
    String? country,
    String? guardianNumber,
    String? guardianType,
  }) async {
    try {
      print("🔵 PROFILE CREATION - Starting profile creation process");
      _isLoading = true;
      notifyListeners();

      // Get current user
      final User? currentUser = _auth.currentUser;
      print("🔵 PROFILE CREATION - Current user: ${currentUser?.uid ?? 'No user found'}");

      if (currentUser == null) {
        print("🔴 PROFILE CREATION ERROR - No authenticated user found");
        throw Exception('No authenticated user found');
      }

      String? profileImageUrl;

      // Upload profile image if provided
      if (profileImagePath != null) {
        print("🔵 PROFILE CREATION - Uploading profile image");
        try {
          profileImageUrl = await _uploadProfileImage(profileImagePath, currentUser.uid);
          print("🔵 PROFILE CREATION - Image uploaded successfully: $profileImageUrl");
        } catch (e) {
          print("🔴 PROFILE CREATION ERROR - Failed to upload image: $e");
          // Continue without image if upload fails
        }
      }

      // Create profile data
      print("🔵 PROFILE CREATION - Creating profile data object");
      final now = Timestamp.now();
      final userProfileData = UserProfile(
        userId: currentUser.uid,
        fullName: fullName,
        dateOfBirth: Timestamp.fromDate(dateOfBirth),
        age: age,
        gender: gender,
        profileImage: profileImageUrl,
        educationLevel: educationLevel,
        profession: profession,
        sect: sect,
        caste: caste, // Added caste to profile data
        smoking: smoking,
        alcohol: alcohol,
        children: children,
        boysCount: boysCount,
        girlsCount: girlsCount,
        height: height,
        maritalStatus: maritalStatus,
        moveAbroad: moveAbroad,
        interests: interests,
        nationalities: nationalities,
        hasSiblings: hasSiblings,
        totalSiblings: totalSiblings,
        brothers: brothers,
        sisters: sisters,
        isFatherAlive: isFatherAlive, // Added father alive status
        isMotherAlive: isMotherAlive, // Added mother alive status
        profileCreatedAt: now,
        profileUpdatedAt: now,
        isVisible: true,
        isVerified: false,
        guardianNumber: guardianNumber,
        guardianType: guardianType,
        address: address,
        city: city,
        country: country,
        homeType: homeType,
      );

      // Convert to map and print for debugging
      final profileMap = userProfileData.toMap();
      print("🔵 PROFILE CREATION - Profile data to save: $profileMap");

      // Save to Firestore
      print("🔵 PROFILE CREATION - Saving to Firestore profiles collection with ID: ${currentUser.uid}");
      try {
        await _firestore
            .collection('profiles')
            .doc(currentUser.uid)
            .set(profileMap);
        print("🔵 PROFILE CREATION - Successfully saved profile to Firestore");
      } catch (e) {
        print("🔴 PROFILE CREATION ERROR - Failed to save profile to Firestore: $e");
        throw e;
      }

      // Update user document to mark profile as complete
      print("🔵 PROFILE CREATION - Updating user document to mark profile as complete");
      try {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'isProfileComplete': true,
          'lastActive': FieldValue.serverTimestamp(),
        });
        print("🔵 PROFILE CREATION - Successfully updated user document");
      } catch (e) {
        print("🔴 PROFILE CREATION ERROR - Failed to update user document: $e");
        // Continue even if this fails
      }

      _currentUserProfile = userProfileData;
      print("🔵 PROFILE CREATION - Profile creation completed successfully");
    } catch (e) {
      print("🔴 PROFILE CREATION ERROR - ${e.toString()}");
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload profile image to Firebase Storage
  Future<String> _uploadProfileImage(String imagePath, String userId) async {
    try {
      // Check if file exists
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist at path: $imagePath');
      }

      // Reference to storage location
      final Reference storageRef = _storage.ref().child('profile_images/$userId.jpg');

      // Start upload with metadata
      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',  // Adjust based on your image type if needed
          customMetadata: {
            'uploaded_by': userId,
            'date': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Monitor upload progress if needed
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      }, onError: (e) {
        print('Upload error: $e');
      });

      // Wait for upload to complete
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage error: [${e.code}] ${e.message}');
      throw Exception('Failed to upload image: ${e.message}');
    } on IOException catch (e) {
      print('File I/O error: $e');
      throw Exception('File error: Unable to read or process the image file');
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Fetch user profile
  Future<UserProfile?> fetchUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      final DocumentSnapshot doc = await _firestore
          .collection('profiles')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        _currentUserProfile = UserProfile.fromFirestore(doc);
        return _currentUserProfile;
      }

      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Add updated timestamp
      data['profileUpdatedAt'] = Timestamp.now();

      await _firestore
          .collection('profiles')
          .doc(currentUser.uid)
          .update(data);

      // Refresh profile data
      await fetchUserProfile();
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if profile exists
  Future<bool> profileExists() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        return false;
      }

      final DocumentSnapshot doc = await _firestore
          .collection('profiles')
          .doc(currentUser.uid)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking if profile exists: $e');
      return false;
    }
  }
}
