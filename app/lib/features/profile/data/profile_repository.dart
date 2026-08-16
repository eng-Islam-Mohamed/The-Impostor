import 'package:bara_alsalfa/features/profile/data/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(firestoreProvider));
});

final userProfileProvider = StreamProvider.family<AppUser?, String>((ref, uid) {
  return ref.watch(profileRepositoryProvider).watchUser(uid);
});

class ProfileRepository {
  const ProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<AppUser?> watchUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromDocument(doc) : null);
  }

  Future<void> saveProfile({
    required User firebaseUser,
    required String displayName,
  }) async {
    final now = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(firebaseUser.uid).set({
      'displayName': displayName.trim(),
      'email': firebaseUser.email?.trim().toLowerCase(),
      'emailVerified': firebaseUser.emailVerified,
      'photoUrl': firebaseUser.photoURL,
      'pairId': null,
      'role': 'member',
      'privateNotifications': true,
      'createdAt': now,
      'updatedAt': now,
    });
    await firebaseUser.updateDisplayName(displayName.trim());
  }
}
