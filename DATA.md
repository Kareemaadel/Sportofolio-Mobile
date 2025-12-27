# Sportofolio - Application Data & Documentation

## App Overview

### Purpose

Sportofolio is a mobile social media platform designed specifically for athletes to showcase their sports journey, achievements, and connect with the athletic community. It serves as a digital portfolio where athletes can build their presence, share their progress, and network with teams, scouts, coaches, and fellow athletes.

### Target Users

- **Athletes**: Amateur and professional athletes looking to showcase their skills and achievements
- **Coaches**: Sports coaches seeking talent and tracking athlete development
- **Scouts**: Professional scouts discovering and evaluating athletic talent
- **Teams**: Sports teams looking to recruit new members
- **Sports Enthusiasts**: Fans following their favorite athletes and sports content

### Overall Functionality

Sportofolio provides a comprehensive platform where users can create profiles, post sports-related content (photos, videos, achievements), interact with other users through likes and comments, build their follower base, and apply for verification badges to establish credibility in the sports community.

---

## Features Implemented

### 1. Authentication System

- **Email/Password Registration**: Users can create accounts using email and password
- **Firebase Authentication**: Secure authentication with reCAPTCHA protection
- **Login/Logout**: Persistent login sessions with secure logout
- **User Initialization**: Automatic profile creation with zero followers/following on registration

### 2. Onboarding Experience

- **Splash Screens**: 4 full-screen onboarding images introducing the app
- **Navigation**: Skip button and Next/Get Started buttons for smooth onboarding flow
- **First-Time Experience**: Displays every time the app launches

### 3. User Profile

- **Profile Display**: Username, bio, role, profile picture, and cover photo
- **Statistics**: Real-time follower and following counts from database
- **Posts Grid**: Visual grid of user's posts with tap-to-view functionality
- **Verification Badge**: Blue checkmark badge for verified accounts
- **Settings Access**: Edit profile information and apply for verification

### 4. Post Management

- **Create Posts**: Upload images with captions using Cloudinary image hosting
- **View Posts**: Instagram-style vertical scrolling post viewer
- **Edit Posts**: Update post captions with real-time database sync
- **Delete Posts**: Remove posts with confirmation dialog
- **Post Details**: Full-screen post view with user info, caption, and engagement metrics

### 5. Home Feed

- **Real-Time Feed**: Display all posts from all users in reverse chronological order
- **User Information**: Profile pictures, usernames, and verification badges
- **Image Display**: Network image support for posts and profile pictures
- **Engagement Stats**: Like and comment counts on each post
- **Stable Scrolling**: Optimized scrolling without jumps or bounces

### 6. Like System

- **Toggle Likes**: Tap heart icon to like/unlike posts
- **Real-Time Counts**: Live update of like counts
- **Persistent State**: Like state saved in Firestore subcollections
- **Visual Feedback**: Red heart icon for liked posts, optimistic UI updates
- **User Tracking**: Each user can only like a post once

### 7. Verification System

- **Apply for Verification**: Users can request verification from settings
- **Badge Display**: Blue checkmark badge shows on profile and all posts
- **Status Management**: Verification status stored in Firestore user documents

### 8. Social Features (Planned)

- **Comments**: Coming soon dialog for comment functionality
- **Share**: Coming soon dialog for sharing posts
- **Follow/Unfollow**: Infrastructure in place for future implementation
- **Direct Messaging**: Planned for future releases

### 9. Search & Discovery

- **Search Screen**: Placeholder for user and content discovery (coming soon)
- **Trials Application**: Placeholder screen for team trials feature

### 10. Settings & Profile Management

- **Edit Profile**: Update name, username, bio, and role
- **Change Profile Picture**: Upload new profile photos
- **Change Cover Photo**: Customize profile banner
- **Theme Toggle**: Switch between light and dark modes
- **Logout**: Secure account logout

### 11. UI/UX Features

- **Bottom Navigation**: Quick access to Home, Search, Add Post, Trials, and Profile
- **Responsive Design**: Adapts to different screen sizes
- **Custom Theme**: Green accent color with dark/light mode support
- **SVG Icons**: Scalable vector graphics for crisp UI elements
- **Smooth Animations**: Page transitions and interactive elements
- **Error Handling**: Safe navigation with proper error checks

---

## Technologies & Tools Used

### Frontend Framework

- **Flutter SDK (^3.9.2)**: Cross-platform mobile development framework
  - Material Design components
  - Custom widgets and layouts
  - State management with StatefulWidget
  - Hot reload for rapid development

### Backend Services

- **Firebase Core (^3.6.0)**: Firebase SDK initialization
- **Firebase Authentication (^5.3.1)**: User authentication and session management
- **Cloud Firestore (^5.4.4)**: NoSQL cloud database for user data, posts, and likes
  - Real-time data synchronization
  - Composite indexes for efficient queries
  - Security rules for data protection
  - Subcollections for likes tracking
- **Firebase Storage (^12.3.4)**: Cloud storage for profile pictures and media

### Image & Media

- **Cloudinary Public (^0.21.0)**: Cloud-based image hosting and CDN
- **Image Picker (^1.0.7)**: Device camera and gallery access
- **Flutter SVG (^2.0.10)**: SVG rendering for icons and graphics

### UI & Styling

- **Google Fonts (^6.1.0)**: Poppins font family integration
- **Custom Theme System**: ThemeService for dark/light mode management

### Utilities

- **Shared Preferences (^2.3.2)**: Local data persistence
- **Timeago (^3.7.0)**: Relative timestamp formatting (e.g., "2 hours ago")
- **Flutter Dotenv (^5.1.0)**: Environment variable management

### Development Tools

- **Flutter Lints (^5.0.0)**: Code quality and best practices enforcement
- **Dart SDK**: Programming language for Flutter development

---

## Database Structure

### Firestore Collections

#### Users Collection

```
users/{userId}
  - username: string
  - email: string
  - bio: string
  - role: string
  - profileImage: string (URL)
  - coverImage: string (URL)
  - followers: number
  - following: number
  - isVerified: boolean
  - createdAt: timestamp
```

#### Posts Collection

```
posts/{postId}
  - postId: string
  - userId: string
  - caption: string
  - mediaUrl: string (URL)
  - likesCount: number
  - commentsCount: number
  - createdAt: timestamp
```

#### Likes Subcollection

```
posts/{postId}/likes/{userId}
  - likedAt: timestamp
```

### Security Rules

- Users can read all posts but only edit/delete their own
- Like counts can be incremented/decremented
- Users can only create/delete their own likes
- Profile data is readable by all, editable by owner only

---

## Project Statistics

- **Total Screens**: 10+ screens
- **Total Services**: 4 (Firebase, Posts, Theme, Cloudinary)
- **Total Models**: 2 (User, Post)
- **Total Widgets**: 15+ custom widgets
- **Lines of Code**: ~3000+ lines
- **Development Time**: Multiple sessions
- **Platform Support**: Android (primary), iOS compatible

---

## Future Enhancements

1. **Comments System**: Full comment functionality with replies
2. **Share Feature**: Share posts to other platforms
3. **Follow System**: Complete follow/unfollow functionality
4. **Direct Messaging**: Private conversations between users
5. **Notifications**: Push notifications for likes, comments, follows
6. **Stories**: Temporary 24-hour content like Instagram stories
7. **Video Support**: Upload and play video content
8. **Search**: Full-text search for users and content
9. **Trials Feature**: Apply for team trials and showcase events
10. **Analytics**: Profile insights and post performance metrics

---

## Contact & Support

**App Name**: Sportofolio  
**Version**: 1.0.0+1  
**Platform**: Flutter Mobile Application  
**Database**: Cloud Firestore  
**Authentication**: Firebase Auth

---

_Last Updated: December 27, 2025_
