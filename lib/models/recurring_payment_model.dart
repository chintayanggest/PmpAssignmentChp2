class RecurringPayment {
  final String id;
  final String userId; // Links to the User
  final String name;
  final double amount;
  final String category;
  final String frequency; // e.g., "Monthly", "Weekly"
  final DateTime? nextPaymentDate;

  RecurringPayment({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.category,
    required this.frequency,
    this.nextPaymentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'amount': amount,
      'category': category,
      'frequency': frequency,
      'nextPaymentDate': nextPaymentDate?.toIso8601String(),
    };
  }

  factory RecurringPayment.fromMap(Map<String, dynamic> map) {
    return RecurringPayment(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      amount: map['amount'],
      category: map['category'],
      frequency: map['frequency'],
      nextPaymentDate: map['nextPaymentDate'] != null
          ? DateTime.parse(map['nextPaymentDate'])
          : null,
    );
  }
}