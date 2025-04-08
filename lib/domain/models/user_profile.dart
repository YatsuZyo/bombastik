import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String? uid;
  final String email;
  final String? name;
  final String? lastName; // Añadido campo lastName
  final String? phone;
  final String? address;
  final String? photoUrl;
  final String role;
  final DateTime createdAt; // Cambiado a no nullable

  UserProfile({
    this.uid,
    required this.email,
    this.name,
    this.lastName, // Añadido
    this.phone,
    this.address,
    this.photoUrl,
    this.role = 'cliente',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserProfile.empty() => UserProfile(email: '', role: 'cliente');

  // Métodos fromMap
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String?,
      email: map['email'] as String? ?? '',
      name: map['name'] as String?,
      lastName: map['lastName'] as String?, // Añadido
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      photoUrl: map['photoUrl'] as String?,
      role: map['role'] as String? ?? 'cliente',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMapForFirestore() {
    final data = {
      if (uid != null) 'uid': uid,
      'email': email,
      if (name != null) 'name': name,
      if (lastName != null) 'lastName': lastName, // Añadido
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(), // Asegúrate de usar FieldValue
    };
    // ignore: avoid_print
    print('Datos a guardar en Firestore: $data');
    return data;
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? name,
    String? lastName, // Añadido
    String? phone,
    String? address,
    String? photoUrl,
    String? role,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName, // Añadido
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Método útil para debugging
  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, name: $name, lastName: $lastName, role: $role)';
  }
}
