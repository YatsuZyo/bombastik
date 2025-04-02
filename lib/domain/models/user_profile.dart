import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String? uid;
  final String email;
  final String? name;
  final String? phone;
  final String? address;
  final String? photoUrl;
  final String role;
  final DateTime? createdAt;

  UserProfile({
    this.uid,
    required this.email,
    this.name,
    this.phone,
    this.address,
    this.photoUrl,
    this.role = 'cliente',
    this.createdAt,
  });
  factory UserProfile.empty() => UserProfile(
    email: '',
    phone: null, // ¡No uses ''!
    address: null,
    role: 'cliente',
  );

  // Métodos fromMap/toMap
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String?,
      email: map['email'] as String,
      name: map['name'] ?? map['displayName'],
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      photoUrl: map['photoUrl'] ?? map['photoURL'],
      role: map['role'] as String? ?? 'cliente',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMapForFirestore() {
    return {
      if (uid != null) 'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toMapForUI() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'photoUrl': photoUrl,
      'role': role,
    };
  }

  // Método copyWith para actualizaciones
  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role,
      createdAt: createdAt,
    );
  }
}
