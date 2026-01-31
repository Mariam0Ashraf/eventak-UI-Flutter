class UserModel {
  final int id;
  String name;
  String email;
  String password;
  int loyaltyPoints;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password = '',
    required this.loyaltyPoints,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'] ?? '',
      loyaltyPoints: json['loyalty_points'] != null 
        ? int.parse(json['loyalty_points'].toString())
        :0,
    );
  }
}
