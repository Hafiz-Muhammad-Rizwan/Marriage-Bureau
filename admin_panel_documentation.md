# Marriage Bureau Admin Panel Documentation

## Overview

This document provides a comprehensive overview of the Marriage Bureau application's admin panel, detailing its functionalities, data models, and implementation details. The admin panel is designed as a separate application to manage the main Marriage Bureau app's data, user profiles, and connection requests.

## System Architecture

The Marriage Bureau system consists of two main applications:

1. **Main User Application**: Flutter app for end users to create profiles and manage connections
2. **Admin Panel Application**: Separate Flutter app for administrators to manage the platform

Both applications connect to the same Firebase backend but with different permission levels:
- User app uses regular Firebase authentication
- Admin app uses Firebase Admin SDK with elevated permissions

## Key Features Implemented

### 1. Authentication & Security

- **Admin Login**: Secure login with email/password authentication
- **Role-based Access**: Support for multiple admin roles (superadmin and regular admin)
- **Session Management**: Token-based authentication with expiration
- **Security Checks**: Validation of admin status before allowing access to admin features

### 2. User Management

- **User Listing**: View all registered users with filtering and search
- **User Profile Details**: Comprehensive view of user information
- **Profile Verification**: Admin can verify user profiles

### 3. Connection Management

- **Connection Monitoring**: View all connection requests between users
- **Status Management**: Admin can accept/reject pending connection requests
- **Connection Statistics**: Dashboard with counts of pending, accepted, and rejected connections

### 4. Dashboard & Analytics

- **Overview Statistics**: Quick view of key metrics (total users, connections, etc.)
- **Recent Activity**: List of recent connection requests
- **Status Breakdown**: Visual representation of connection request statuses

## Data Models

### 1. UserProfile Model

```dart
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
  final String? caste;
  final String? smoking;
  final String? alcohol;
  final String? children;
  final String? boysCount;
  final String? girlsCount;
  final String? height;
  final String? maritalStatus;
  final String? moveAbroad;
  final List<String>? interests;
  final List<String>? nationalities;
  final Timestamp profileCreatedAt;
  final Timestamp profileUpdatedAt;
  final bool isVisible;
  final bool isVerified;
  final bool? hasSiblings;
  final int? totalSiblings;
  final int? brothers;
  final int? sisters;
  final bool? isFatherAlive;
  final bool? isMotherAlive;
  final String? email;
  final String? phoneNumber;
}
```

### 2. ConnectionRequest Model

```dart
enum ConnectionStatus {
  pending,
  accepted,
  rejected
}

class ConnectionRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final ConnectionStatus status;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final String? senderName;
  final String? receiverName;
  final String? senderProfileImage;
  final String? receiverProfileImage;
  final String? message;
}
```

## Firebase Database Structure

```
firebase/
  ├── authentication/
  │   └── admin users with custom claims for roles
  ├── firestore/
  │   ├── users/
  │   │   └── user documents with authentication data
  │   ├── profiles/
  │   │   └── user profile information
  │   ├── connectionRequests/
  │   │   └── connection request data
  │   ├── admins/
  │   │   └── admin permissions and roles
  │   └── notifications/
  │       └── user notifications for connections
  └── storage/
      └── profile_images/
          └── user profile photos
```

## Admin Services Implementation

The `AdminService` class is the core service that handles all admin-related functionality:

```dart
class AdminService extends ChangeNotifier {
  // Authentication management
  Future<bool> adminLogin(String email, String password);
  Future<void> logout();
  Future<bool> checkIfAdmin();
  
  // Data fetching
  Future<void> fetchAllProfiles();
  Future<void> fetchAllConnectionRequests();
  
  // Statistics
  Future<Map<String, int>> getConnectionStatistics();
  
  // Connection management
  Future<bool> updateConnectionStatus(String requestId, ConnectionStatus status);
  Future<void> notifyUsersOfConnection(String senderId, String recipientId);
}
```

## Admin UI Components

### 1. Admin Dashboard Screen
- Overview statistics
- Recent connection activity
- Navigation to other admin features

### 2. All Profiles Tab
- List view of all user profiles
- Search and filter functionality
- Quick access to profile details

### 3. Connection Requests Tab
- Tabbed view of all/pending/accepted/rejected connections
- Ability to update connection status
- Search functionality

### 4. Profile Detail Screen
- Comprehensive view of user information
- Sections for personal, educational, family information
- Well-organized display of all profile data

### 5. Connection Detail Screen
- Detailed view of connection between two users
- Status information and history
- Quick links to involved profiles
- Action buttons for status updates

## Implementation Notes

### Security Considerations
- Admin status is verified before allowing access to admin features

- Firestore security rules prevent unauthorized access

### Performance Optimizations
- Pagination for large data sets
- Efficient data loading with loading indicators
- Search functionality to quickly find specific records

### User Experience
- Clean, organized dashboard with key metrics
- Consistent design language across the admin panel
- Responsive design for various screen sizes
- Clear feedback for admin actions

## Admin Panel Launch Process

1. Log in with admin credentials
2. Dashboard loads with key statistics
3. Navigate to profiles or connections as needed
4. Take administrative actions as required


---
This documentation provides a comprehensive overview of the Marriage Bureau Admin Panel implementation. It should be used as a reference for understanding the system architecture, available features, and implementation details.
