import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommerceProfile {
  final String? uid;
  final String companyName;
  final String rif;  // Formato: J123456789
  final String email;
  final String phone;  // Ahora requerido
  final String address;  // Ahora requerido
  final String category;  // Ahora requerido
  final DateTime createdAt;
  final bool isActive;

  CommerceProfile({
    this.uid,
    required this.companyName,
    required this.rif,
    required this.email,
    required this.phone,
    required this.address,
    required this.category,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  // Validador de RIF
  static bool isValidRif(String rif) {
    final rifRegex = RegExp(r'^J\d{9}$');
    return rifRegex.hasMatch(rif);
  }

  // Validador de teléfono venezolano
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+58[0-9]{10}$');  // Formato: +58XXXXXXXXXX
    return phoneRegex.hasMatch(phone);
  }

  // Lista de categorías disponibles
  static List<String> get availableCategories => [
    'Alimentos y Bebidas',
    'Ropa y Accesorios',
    'Electrónica',
    'Hogar y Decoración',
    'Salud y Belleza',
    'Deportes',
    'Juguetes',
    'Mascotas',
    'Libros y Papelería',
    'Otros',
  ];

  // Mapa de iconos para categorías
  static Map<String, IconData> get categoryIcons => {
    'Alimentos y Bebidas': Icons.restaurant,
    'Ropa y Accesorios': Icons.shopping_bag,
    'Electrónica': Icons.devices,
    'Hogar y Decoración': Icons.home,
    'Salud y Belleza': Icons.spa,
    'Deportes': Icons.sports_soccer,
    'Juguetes': Icons.toys,
    'Mascotas': Icons.pets,
    'Libros y Papelería': Icons.book,
    'Otros': Icons.more_horiz,
  };

  factory CommerceProfile.empty() => CommerceProfile(
    companyName: '',
    rif: '',
    email: '',
    phone: '',
    address: '',
    category: availableCategories.first,
  );

  factory CommerceProfile.fromMap(Map<String, dynamic> map) {
    return CommerceProfile(
      uid: map['uid'] as String?,
      companyName: map['companyName'] as String? ?? '',
      rif: map['rif'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      category: map['category'] as String? ?? availableCategories.first,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (uid != null) 'uid': uid,
      'companyName': companyName,
      'rif': rif,
      'email': email,
      'phone': phone,
      'address': address,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': isActive,
      'role': 'commerce',
    };
  }

  CommerceProfile copyWith({
    String? uid,
    String? companyName,
    String? rif,
    String? email,
    String? phone,
    String? address,
    String? category,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return CommerceProfile(
      uid: uid ?? this.uid,
      companyName: companyName ?? this.companyName,
      rif: rif ?? this.rif,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'CommerceProfile(uid: $uid, companyName: $companyName, rif: $rif, email: $email, category: $category)';
  }
} 