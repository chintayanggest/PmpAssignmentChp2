class TransactionModel {
  final String id;
  final String userId; // Links to the User
  final String title;
  final double amount;
  final DateTime date;
  final String categoryName;
  final bool isExpense; // true = Expense, false = Income

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryName,
    required this.isExpense,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryName': categoryName,
      'isExpense': isExpense ? 1 : 0, // SQLite stores booleans as 0 or 1
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      categoryName: map['categoryName'],
      isExpense: map['isExpense'] == 1,
    );
  }
}