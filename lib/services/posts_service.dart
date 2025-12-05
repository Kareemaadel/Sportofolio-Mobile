import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';

class PostsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create a new post
  Future<String?> createPost({
    required String caption,
    required String mediaUrl,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final docRef = await _firestore.collection('posts').add({
        'userId': userId,
        'caption': caption,
        'mediaUrl': mediaUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'commentsCount': 0,
      });

      return docRef.id;
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // Get posts by user ID (for profile screen)
  Stream<List<Post>> getUserPosts(String userId) {
    try {
      return _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
      }).handleError((error) {
        print('❌ Error in getUserPosts stream: $error');
        // If there's an index error, Firebase will provide a link in the error
        if (error.toString().contains('index')) {
          print('⚠️ Firestore index required! Check the error link above.');
        }
        return <Post>[];
      });
    } catch (e) {
      print('❌ Error setting up getUserPosts stream: $e');
      // Return empty stream on error
      return Stream.value([]);
    }
  }

  // Get all posts (for home feed)
  Stream<List<Post>> getAllPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
    });
  }

  // Get a single post by ID
  Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        return Post.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting post: $e');
      return null;
    }
  }

  // Update post caption
  Future<bool> updatePostCaption(String postId, String newCaption) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'caption': newCaption,
      });
      return true;
    } catch (e) {
      print('Error updating post: $e');
      return false;
    }
  }

  // Delete a post
  Future<bool> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // Increment likes count
  Future<bool> incrementLikes(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Error incrementing likes: $e');
      return false;
    }
  }

  // Decrement likes count
  Future<bool> decrementLikes(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(-1),
      });
      return true;
    } catch (e) {
      print('Error decrementing likes: $e');
      return false;
    }
  }

  // Increment comments count
  Future<bool> incrementComments(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Error incrementing comments: $e');
      return false;
    }
  }

  // Get posts count for a user
  Future<int> getUserPostsCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting posts count: $e');
      return 0;
    }
  }
}
