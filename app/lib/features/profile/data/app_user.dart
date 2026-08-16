import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.emailVerified,
    required this.privateNotifications,
    this.photoUrl,
    this.pairId,
  });

  final String id;
  final String displayName;
  final String email;
  final bool emailVerified;
  final bool privateNotifications;
  final String? photoUrl;
  final String? pairId;

  bool get hasProfile => displayName.trim().isNotEmpty;

  factory AppUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AppUser(
      id: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      emailVerified: data['emailVerified'] as bool? ?? false,
      privateNotifications: data['privateNotifications'] as bool? ?? true,
      photoUrl: data['photoUrl'] as String?,
      pairId: data['pairId'] as String?,
    );
  }
}
