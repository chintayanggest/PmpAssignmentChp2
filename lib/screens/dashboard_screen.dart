// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../models/unified_models.dart'; // EXCLUSIVE IMPORT: Contains TransactionType, TransactionModel, etc.
// DO NOT import transaction_type.dart here
// DO NOT import transaction.dart here

import 'add_transaction_screen.dart';
import 'category_transactions_screen.dart';
import 'manage_accounts_screen.dart';
import 'manage_categories_screen.dart';
import 'transaction_detail_screen.dart';
import '../widgets/transaction_chart.dart';

enum FilterPeriod { daily, monthly, yearly }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FilterPeriod _selectedPeriod = FilterPeriod.daily;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<TransactionProvider>(context, listen: false).fetchData(user.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToPreviousPeriod() {
    setState(() {
      if (_selectedPeriod == FilterPeriod.daily) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      } else if (_selectedPeriod == FilterPeriod.monthly) {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      } else {
        _selectedDate = DateTime(_selectedDate.year - 1);
      }
    });
  }

  void _goToNextPeriod() {
    setState(() {
      final now = DateTime.now();
      if (_selectedPeriod == FilterPeriod.daily) {
        if (_selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day) return;
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      } else if (_selectedPeriod == FilterPeriod.monthly) {
        if (_selectedDate.year == now.year && _selectedDate.month >= now.month) return;
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      } else {
        if (_selectedDate.year >= now.year) return;
        _selectedDate = DateTime(_selectedDate.year + 1);
      }
    });
  }

  List<TransactionModel> _getFilteredTransactions(List<TransactionModel> allTransactions) {
    return allTransactions.where((tx) {
      if (_selectedPeriod == FilterPeriod.daily) {
        return tx.date.year == _selectedDate.year &&
            tx.date.month == _selectedDate.month &&
            tx.date.day == _selectedDate.day;
      } else if (_selectedPeriod == FilterPeriod.monthly) {
        return tx.date.year == _selectedDate.year && tx.date.month == _selectedDate.month;
      } else {
        return tx.date.year == _selectedDate.year;
      }
    }).toList();
  }

  String _getFormattedDate() {
    final List<String> _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    if (_selectedPeriod == FilterPeriod.daily) {
      return '${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year}';
    } else if (_selectedPeriod == FilterPeriod.monthly) {
      return '${_months[_selectedDate.month - 1]} ${_selectedDate.year}';
    } else {
      return '${_selectedDate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final allFilteredTransactions = _getFilteredTransactions(transactionProvider.transactions);

        final expenseTransactions = allFilteredTransactions
            .where((tx) => tx.type == TransactionType.expense).toList();
        final incomeTransactions = allFilteredTransactions
            .where((tx) => tx.type == TransactionType.income).toList();

        return Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.deepPurple),
                  child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('Rekening (Accounts)'),
                  onTap:() {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder:(context) => const ManageAccountsScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Kategori (Categories)'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()));
                  },
                ),
              ],
            ),
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: Colors.deepPurple,
                  pinned: true,
                  floating: true,
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Colors.deepPurple,
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          const Text('Total Balance', style: TextStyle(fontSize: 18, color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text(
                            'Rp${transactionProvider.totalBalance.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    controller: _tabController,
                    tabs: const [ Tab(text: 'Expenses'), Tab(text: 'Income'), ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        SegmentedButton<FilterPeriod>(
                          segments: const [
                            ButtonSegment(value: FilterPeriod.daily, label: Text('Day')),
                            ButtonSegment(value: FilterPeriod.monthly, label: Text('Month')),
                            ButtonSegment(value: FilterPeriod.yearly, label: Text('Year')),
                          ],
                          selected: {_selectedPeriod},
                          onSelectionChanged: (Set<FilterPeriod> newSelection) {
                            setState(() {
                              _selectedPeriod = newSelection.first;
                              _selectedDate = DateTime.now();
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(icon: const Icon(Icons.chevron_left), onPressed: _goToPreviousPeriod),
                            Text(
                              _getFormattedDate(),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(icon: const Icon(Icons.chevron_right), onPressed: _goToNextPeriod),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    Container(
                      height: 220,
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: TransactionChart(transactions: expenseTransactions, type: TransactionType.expense),
                    ),
                    const Divider(),
                    Expanded(child: TransactionListView(transactions: expenseTransactions)),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      height: 220,
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: TransactionChart(transactions: incomeTransactions, type: TransactionType.income),
                    ),
                    const Divider(),
                    Expanded(child: TransactionListView(transactions: incomeTransactions)),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF7B45DA),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen()));
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}

class TransactionListView extends StatelessWidget {
  final List<TransactionModel> transactions;
  const TransactionListView({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) { return const Center( child: Text('No transactions in this period yet.'), ); }
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isExpense = transaction.type == TransactionType.expense;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: transaction.category.color.withOpacity(0.2),
            child: Icon(transaction.category.icon, color: transaction.category.color),
          ),
          title: Text(transaction.category.name),
          subtitle: Text(transaction.notes ?? transaction.account.name),
          trailing: Text(
            '${isExpense ? '-' : '+'}Rp${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: isExpense ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailScreen(transaction: transaction),
              ),
            );
          },
        );
      },
    );
  }
}