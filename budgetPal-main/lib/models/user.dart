class Appuser {
  final String id;
  final String name;
  final String email;

Appuser({
  required this.id,
   required this.name,
   required this.email
   });
}

class UserModel{
  String id;
  String name;
  String email;

  UserModel copyWithId(String newId) {
    return UserModel(
      id: newId,
      name: name,
      email: email,
    );
  }

  UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }
}