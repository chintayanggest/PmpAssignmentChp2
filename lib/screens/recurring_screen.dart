// lib/screens/recurring_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/unified_models.dart';
import '../providers/recurring_provider.dart';
import '../providers/auth_provider.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String? _editingId;
  String? _selectedCategory;
  String _selectedFrequency = 'Monthly';
  DateTime? _selectedDate;

  // Colors
  final Color _bgBlack = const Color(0xFF121212);
  final Color _neonGreen = const Color(0xFFC6FF00);
  final Color _cardWhite = const Color(0xFFFFFFFF);
  final Color _inputGrey = const Color(0xFFF5F5F5);

  final List<String> _categories = [
    'Entertainment', 'Music', 'Utilities', 'Insurance', 'Subscription',
    'Food', 'Transportation', 'Health', 'Education', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<RecurringProvider>(context, listen: false).fetchPayments(user.id);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // --- FORM DIALOG (Kept mostly the same logic, ensure UI matches) ---
  void _showRecurringForm({RecurringPayment? payment}) {
    if (payment != null) {
      _editingId = payment.id;
      _nameController.text = payment.name;
      _amountController.text = payment.amount.toStringAsFixed(0);
      _selectedCategory = payment.category;
      _selectedFrequency = payment.frequency;
      _selectedDate = payment.nextPaymentDate;
    } else {
      _editingId = null;
      _nameController.clear();
      _amountController.clear();
      _selectedCategory = null;
      _selectedFrequency = 'Monthly';
      _selectedDate = null;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              insetPadding: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: _neonGreen, borderRadius: BorderRadius.circular(8)),
                              child: Icon(_editingId == null ? Icons.add_circle_outline : Icons.edit, color: Colors.black, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _editingId == null ? 'Add Recurring Payment' : 'Edit Recurring',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('Payment Name'),
                        _buildCustomTextField(controller: _nameController, hint: 'Netflix...', icon: Icons.subscriptions_outlined),
                        const SizedBox(height: 16),
                        _buildLabel('Amount (Rp)'),
                        _buildCustomTextField(controller: _amountController, hint: '50000', icon: Icons.money, isNumber: true),
                        const SizedBox(height: 16),
                        _buildLabel('Category'),
                        _buildCustomDropdown(value: _selectedCategory, icon: Icons.category_outlined, items: _categories, onChanged: (val) => setStateDialog(() => _selectedCategory = val)),
                        const SizedBox(height: 16),
                        _buildLabel('Frequency'),
                        _buildCustomDropdown(value: _selectedFrequency, icon: Icons.repeat, items: ['Monthly', 'Weekly', 'Yearly'], onChanged: (val) => setStateDialog(() => _selectedFrequency = val!)),
                        const SizedBox(height: 16),
                        _buildLabel('Next Payment Date'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 22, color: Colors.black87),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(color: _inputGrey, borderRadius: BorderRadius.circular(12)),
                                child: Text(_selectedDate == null ? 'Not selected' : DateFormat('dd MMM yyyy').format(_selectedDate!), style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black87, fontWeight: FontWeight.w500)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: _bgBlack, foregroundColor: _neonGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), elevation: 0),
                              onPressed: () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate ?? now,
                                  firstDate: now,
                                  lastDate: DateTime(2030),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.dark(primary: _neonGreen, onPrimary: Colors.black, surface: _bgBlack, onSurface: Colors.white),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) setStateDialog(() => _selectedDate = picked);
                              },
                              child: const Text('Select', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600))),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: _bgBlack, foregroundColor: _neonGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), elevation: 0),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (_selectedDate == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a date!')));
                                    return;
                                  }
                                  final user = Provider.of<AuthProvider>(context, listen: false).user;
                                  final provider = Provider.of<RecurringProvider>(context, listen: false);
                                  final paymentObj = RecurringPayment(
                                    id: _editingId ?? const Uuid().v4(),
                                    userId: user!.id,
                                    name: _nameController.text,
                                    amount: double.parse(_amountController.text),
                                    category: _selectedCategory ?? 'Other',
                                    frequency: _selectedFrequency,
                                    nextPaymentDate: _selectedDate,
                                  );
                                  if (_editingId == null) {
                                    await provider.addPayment(paymentObj);
                                  } else {
                                    await provider.updatePayment(paymentObj);
                                  }
                                  Navigator.pop(dialogContext);
                                }
                              },
                              child: Text(_editingId == null ? 'Add' : 'Save', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- BOTTOM SHEET MENU ---
  void _showOptionsBottomSheet(RecurringPayment payment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _neonGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.edit, color: Colors.black)),
                title: const Text('Edit Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Modify details'),
                onTap: () { Navigator.pop(context); _showRecurringForm(payment: payment); },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.refresh, color: Colors.blue)),
                title: const Text('Simulate Next Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Jump to next due date'),
                onTap: () { Navigator.pop(context); _simulateNextPayment(payment); },
              ),
              const Divider(height: 24),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete, color: Colors.red)),
                title: const Text('Delete Payment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                subtitle: const Text('Remove permanently'),
                onTap: () { Navigator.pop(context); _confirmDelete(payment.id); },
              ),
            ],
          ),
        );
      },
    );
  }

  void _simulateNextPayment(RecurringPayment item) {
    if (item.nextPaymentDate == null) return;
    final currentDate = item.nextPaymentDate!;
    final newDate = item.frequency == 'Monthly' ? DateTime(currentDate.year, currentDate.month + 1, currentDate.day) : currentDate.add(const Duration(days: 7));
    final updatedPayment = RecurringPayment(id: item.id, userId: item.userId, name: item.name, amount: item.amount, category: item.category, frequency: item.frequency, nextPaymentDate: newDate);
    Provider.of<RecurringProvider>(context, listen: false).updatePayment(updatedPayment);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Simulated! Next date: ${DateFormat('d MMM yyyy').format(newDate)}")));
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Payment?'),
        content: const Text('Are you sure you want to remove this?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () { final user = Provider.of<AuthProvider>(context, listen: false).user; Provider.of<RecurringProvider>(context, listen: false).deletePayment(id, user!.id); Navigator.pop(ctx); }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payments = Provider.of<RecurringProvider>(context).payments;
    final total = payments.fold(0.0, (sum, item) => sum + item.amount);
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: _bgBlack,
      appBar: AppBar(
        backgroundColor: _bgBlack,
        elevation: 0,
        centerTitle: true,
        title: Text("Recurring Payments", style: TextStyle(color: _neonGreen, fontWeight: FontWeight.bold, fontSize: 20)),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // 1. SUMMARY CARD (Updated Layout)
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(color: _neonGreen, borderRadius: BorderRadius.circular(30)),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.account_balance_wallet_outlined, color: _neonGreen, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Monthly Total", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black)),
                        Text("All recurring payments", style: TextStyle(fontSize: 12, color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Black Amount Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                  child: Center(
                    child: Text(
                      formatCurrency.format(total).replaceAll("Rp", "Rp "),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _neonGreen),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. LIST HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Payment List", style: TextStyle(color: _neonGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _neonGreen, borderRadius: BorderRadius.circular(20)),
                  child: Text("${payments.length} Items", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ],
            ),
          ),

          // 3. LIST CONTENT
          Expanded(
            child: payments.isEmpty
            // EMPTY STATE (Updated Icon)
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: _neonGreen.withOpacity(0.1), // Darkish circle
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.receipt_long, size: 60, color: _neonGreen.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 20),
                  Text("Tap the + button to add one", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final item = payments[index];
                return GestureDetector(
                  onTap: () => _showOptionsBottomSheet(item),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: _cardWhite, borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Container(width: 4, height: 50, decoration: BoxDecoration(color: _neonGreen, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)), child: Text(item.category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
                                  const SizedBox(width: 6),
                                  Text("• ${item.frequency}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              if (item.nextPaymentDate != null) ...[
                                const SizedBox(height: 4),
                                Text(DateFormat('dd MMM yyyy').format(item.nextPaymentDate!), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ]
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(formatCurrency.format(item.amount).replaceAll("Rp", "Rp "), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            const SizedBox(height: 8),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _neonGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(6)), child: const Text("Details", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 56,
        width: 110,
        child: FloatingActionButton(
          onPressed: () => _showRecurringForm(),
          backgroundColor: _neonGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.black),
              SizedBox(width: 8),
              Text("Add", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)));
  Widget _buildCustomTextField({required TextEditingController controller, required String hint, required IconData icon, bool isNumber = false}) {
    return TextFormField(controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.black38, fontSize: 14), prefixIcon: Icon(icon, color: Colors.black54, size: 20), filled: true, fillColor: _inputGrey, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12)), validator: (val) => val!.isEmpty ? 'Required' : null);
  }
  Widget _buildCustomDropdown({required String? value, required IconData icon, required List<String> items, required Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(value: value, icon: const Icon(Icons.arrow_drop_down, color: Colors.black54), decoration: InputDecoration(prefixIcon: Icon(icon, color: Colors.black54, size: 20), filled: true, fillColor: _inputGrey, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12)), items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChanged, validator: (val) => val == null ? 'Required' : null);
  }
}