class UserModel {
  final String id;
  final String phone;
  final String? name;
  final String? role;

  UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      phone: map['phone'],
      name: map['name'],
      role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'role': role,
    };
  }
}
