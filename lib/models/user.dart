class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String subscriptionStatus;
  final int amountToPay;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.subscriptionStatus,
    required this.amountToPay,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      subscriptionStatus: json['subscriptionStatus'],
      amountToPay: json['amountToPay'],
    );
  }
}
