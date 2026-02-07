import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afya_id/data/models/models.dart';

class UserFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Create a new user
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'utilisateur: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'utilisateur: $e');
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la recherche de l\'utilisateur: $e');
    }
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.id)
          .update(user.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'utilisateur: $e');
    }
  }

  // Update last login
  // Future<void> updateLastLogin(String userId) async {
  //   try {
  //     await updateUser(userId, {'lastLogin': Timestamp.now()});
  //   } catch (e) {
  //     throw Exception(
  //       'Erreur lors de la mise à jour de la dernière connexion: $e',
  //     );
  //   }
  // }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }

  // Stream user
  Stream<UserModel?> streamUser(String userId) {
    return _firestore.collection(_collection).doc(userId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Stream all users
  Stream<List<UserModel>> streamAllUsers() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('role', isEqualTo: role)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erreur lors du filtrage par rôle: $e');
    }
  }

  // Get active users
  Future<List<UserModel>> getActiveUsers() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des utilisateurs actifs: $e',
      );
    }
  }

  // Toggle user active status
  // Future<void> toggleUserStatus(String userId, bool isActive) async {
  //   try {
  //     await updateUser(userId, {'isActive': isActive});
  //   } catch (e) {
  //     throw Exception('Erreur lors du changement de statut: $e');
  //   }
  // }

  // Search users by name
  Future<List<UserModel>> searchUsersByName(String query) async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      return users.where((user) {
        final fullName = user.fullName.toLowerCase();
        return fullName.contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }
}
