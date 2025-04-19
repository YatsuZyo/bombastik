import 'package:cloud_firestore/cloud_firestore.dart';

class Commerce {
  final String id;
  final String name;
  final String description;
  final String category;
  final String location;
  final String? imageUrl;
  final double rating;
  final int totalRatings;
  final bool isOpen;
  final int availableProducts;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Commerce({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    this.imageUrl,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.isOpen = true,
    this.availableProducts = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory Commerce.fromMap(Map<String, dynamic> map) {
    return Commerce(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      location: map['location'] as String,
      imageUrl: map['imageUrl'] as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['totalRatings'] as int? ?? 0,
      isOpen: map['isOpen'] as bool? ?? true,
      availableProducts: map['availableProducts'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'location': location,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalRatings': totalRatings,
      'isOpen': isOpen,
      'availableProducts': availableProducts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Commerce copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? location,
    String? imageUrl,
    double? rating,
    int? totalRatings,
    bool? isOpen,
    int? availableProducts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Commerce(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      isOpen: isOpen ?? this.isOpen,
      availableProducts: availableProducts ?? this.availableProducts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 