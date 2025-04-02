import 'package:bombastik/domain/models/user_profile.dart';
import 'package:bombastik/infrastructure/services/firestore_service.dart';

class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository(this._firestoreService);

  Future<void> createUser(UserProfile user) async {
    await _firestoreService.setDocument(
      collection: 'users',
      id: user.uid!,
      data: user.toMapForFirestore(),
    );
  }

  Future<UserProfile?> getUser(String userId) async {
    final doc = await _firestoreService.getDocument('users', userId);
    if (!doc.exists) return null;

    final data = doc.data();
    if (data is! Map<String, dynamic>) {
      throw FormatException('Document data is not a Map<String, dynamic>');
    }
    return UserProfile.fromMap(data);
  }
}
