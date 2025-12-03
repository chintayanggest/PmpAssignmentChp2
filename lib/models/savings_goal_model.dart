class SavingsGoal {
  final String id;
  final String userId; // Links to the User
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? imagePath;

  SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.targetDate,
    this.imagePath,
  });

  // Helper to calculate progress (0.0 to 1.0)
  double get progress {
    if (targetAmount <= 0) return 0.0;
    double p = currentAmount / targetAmount;
    return p > 1.0 ? 1.0 : p;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate?.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
      imagePath: map['imagePath'],
    );
  }
}