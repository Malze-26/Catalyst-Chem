class UserModel {
  final String id;
  final String name;
  final String email;
  final String targetBoard;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.targetBoard,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      targetBoard: json['target_board'] ?? 'Edexcel',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'target_board': targetBoard,
    };
  }
}
