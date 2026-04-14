class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String preferredUnit; // 'km' or 'mi'
  final String? boatType; // kayak_single, kayak_double, canoe, dragon_boat, sup, outrigger
  final String? sportType; // paddling, cycling
  final int maxHeartRate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.preferredUnit = 'km',
    this.boatType,
    this.sportType,
    this.maxHeartRate = 200,
    required this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    String? preferredUnit,
    String? boatType,
    String? sportType,
    int? maxHeartRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      boatType: boatType ?? this.boatType,
      sportType: sportType ?? this.sportType,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'preferredUnit': preferredUnit,
      'boatType': boatType,
      'sportType': sportType,
      'maxHeartRate': maxHeartRate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      preferredUnit: map['preferredUnit'] ?? 'km',
      boatType: map['boatType'],
      sportType: map['sportType'],
      maxHeartRate: map['maxHeartRate'] ?? 200,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory User.fromJson(Map<String, dynamic> json) => User.fromMap(json);
}
