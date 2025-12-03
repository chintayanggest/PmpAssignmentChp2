class User {
  final String id;
  final String name;
  final String email;
  final String password; // Added password for auth logic
  final String preferredCurrency;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.preferredCurrency = 'IDR',
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'email': email, 'password': password, 'preferredCurrency': preferredCurrency,
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'], name: map['name'], email: map['email'], password: map['password'], preferredCurrency: map['preferredCurrency'],
  );
}