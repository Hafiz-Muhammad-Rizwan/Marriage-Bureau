# Marriage Bureau Admin Panel Design Document

## Overview
This document outlines the requirements, architecture, and implementation plan for a separate admin panel application for the Marriage Bureau platform. The admin panel will be separated from the main user app to improve performance, security, and maintainability.

## Benefits of a Separate Admin App
1. **Reduced user app size** - The main app won't include admin-specific code and dependencies
2. **Enhanced security** - Admin features aren't compiled into the user app
3. **Better performance** - The user app loads faster without admin-related code
4. **Independent development cycles** - Update the admin panel without releasing a new user app version
5. **Focused UX** - Each app has an interface optimized for its specific users

## Admin Panel Features

### 1. Authentication & Security
- **Admin Login** - Secure login with email/password authentication
- **Role-based access** - Super admin, moderator, support roles with different permissions
- **Session management** - Token-based authentication with expiration
- **Activity logging** - Track admin actions for accountability

### 2. User Management
- **User listing** - View all registered users with filtering options
- **User details** - View complete user profiles
- **User verification** - Manually verify user profiles and documents
- **User moderation** - Ban/suspend problematic users
- **Direct messaging** - Contact users through the system

### 3. Profile Moderation
- **Profile review queue** - New profiles awaiting approval
- **Content moderation** - Flag/remove inappropriate content in profiles
- **Photo verification** - Verify that profile photos match submitted ID
- **Manual verification** - Assign verification badges to trusted profiles

### 4. Connection Management
- **Connection monitoring** - View active and pending connections
- **Issue resolution** - Handle reported problems with connections
- **Statistics view** - Monitor connection success rates

### 5. Payment & Subscription Management
- **Subscription plans** - Create/edit subscription plans
- **Payment history** - View transaction records
- **Refund processing** - Process refund requests
- **Subscription status** - View active/expired subscriptions

### 6. Content Management
- **Success stories** - Add/edit featured success stories
- **FAQ management** - Update frequently asked questions
- **Terms & policies** - Update legal documents
- **Announcements** - Create system-wide announcements

### 7. Reporting & Analytics
- **User statistics** - Registration trends, active users, etc.
- **Connection metrics** - Connection success rates, popular users
- **Revenue reports** - Subscription sales, premium features
- **Usage statistics** - Feature popularity, user engagement
- **Custom reports** - Generate reports for specific timeframes

### 8. System Configuration
- **App settings** - Modify global app parameters
- **Notification templates** - Edit system notification templates
- **Feature toggles** - Enable/disable specific app features

## Technical Architecture

### 1. Backend Sharing
- Both apps will connect to the same Firebase backend
- Admin app will use admin SDK with elevated permissions

### 2. Firebase Structure
```
firebase/
  ├── authentication/
  │   └── admin users with custom claims for roles
  ├── firestore/
  │   ├── users/
  │   ├── profiles/
  │   ├── connections/
  │   ├── admin_logs/
  │   ├── reports/
  │   ├── system_settings/
  │   └── content/
  ├── storage/
  │   ├── profile_images/
  │   ├── verification_documents/
  │   └── content_images/
  └── functions/
      ├── admin/ (admin-only endpoints)
      └── app/ (shared endpoints)
```

### 3. Security Rules
- Strict security rules to prevent regular users from accessing admin collections
- Admin app will use admin SDK that bypasses security rules

## UI/UX Design Guidelines

### 1. Admin Panel Layout
- **Dashboard** - Overview with key metrics
- **Sidebar navigation** - Quick access to main sections
- **Responsive design** - Works on desktop and tablets
- **Dark/light mode** - Support for both themes
- **Batch operations** - Efficiently handle multiple items

### 2. Admin-Specific Components
- **Data tables** - Sortable and filterable user lists
- **Analytics cards** - Visual representations of key metrics
- **Action logs** - Timeline of admin activities
- **Approval workflows** - Multi-step review processes

## Implementation Plan

### Phase 1: Foundation
1. Set up a separate Flutter project for the admin app
2. Implement admin authentication system
3. Create dashboard with basic user management
4. Establish shared code libraries between apps

### Phase 2: Core Features
1. Implement profile verification workflow
2. Add user moderation capabilities
3. Develop reporting and analytics
4. Build content management system

### Phase 3: Advanced Features
1. Implement payment and subscription management
2. Add role-based access control
3. Develop advanced analytics
4. Create custom report generation

### Phase 4: Optimization
1. Performance optimization
2. Security auditing
3. UX improvements
4. Documentation and training materials

## Firebase Configuration
- Create a separate Firebase app configuration for the admin panel
- Use Service Account for admin operations
- Implement proper security rules to protect admin routes

## Shared Resources
- Certain models, utilities, and Firebase configurations can be shared between both apps
- Consider creating a separate package for shared code

## Security Considerations
- Admin app should use IP restrictions where possible
- Implement 2FA for admin accounts
- Log all sensitive operations
- Regular security audits of permissions

## Deployment Strategy
- Different build pipelines for admin and user apps
- Web deployment for admin panel (easier to use on desktop)
- Consider a private app distribution for mobile admin app

## Monitoring and Maintenance
- Error tracking specific to admin operations
- Usage analytics for admin actions
- Regular security updates
- Backup strategy for admin operations
