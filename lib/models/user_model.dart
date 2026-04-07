import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String address;
  final String city;
  final String zipCode;
  final bool isAdmin;
  final String? profileImage;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.city,
    required this.zipCode,
    required this.isAdmin,
    this.profileImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'city': city,
      'zipCode': zipCode,
      'isAdmin': isAdmin,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    // Handle Timestamp conversion safely
    DateTime createdAt;
    if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is DateTime) {
      createdAt = map['createdAt'] as DateTime;
    } else {
      createdAt = DateTime.now();
    }

    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      zipCode: map['zipCode'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      profileImage: map['profileImage'],
      createdAt: createdAt,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? address,
    String? city,
    String? zipCode,
    bool? isAdmin,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      isAdmin: isAdmin ?? this.isAdmin,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
