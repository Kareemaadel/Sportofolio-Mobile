import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String userId;
  final String caption;
  final String mediaUrl;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;

  Post({
    required this.postId,
    required this.userId,
    required this.caption,
    required this.mediaUrl,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
  });

  // Factory constructor to create Post from Firestore document
  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Post(
      postId: doc.id,
      userId: data['userId'] ?? '',
      caption: data['caption'] ?? '',
      mediaUrl: data['mediaUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
    );
  }

  // Convert Post to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'caption': caption,
      'mediaUrl': mediaUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
    };
  }

  // Create a copy with updated fields
  Post copyWith({
    String? postId,
    String? userId,
    String? caption,
    String? mediaUrl,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      caption: caption ?? this.caption,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }
}
