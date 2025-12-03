// lib/screens/add_transaction_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/unified_models.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transactionToEdit;
  const AddTransactionScreen({super.key, this.transactionToEdit});
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late TabController _tabController;

  TransactionCategory? _selectedCategory;
  Account? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  final List<XFile> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false; // Added loading state

  bool get _isEditing => widget.transactionToEdit != null;

  @override
  void initState() {
    super.initState();

    int initialIndex = 0;
    if (_isEditing && widget.transactionToEdit!.type == TransactionType.income) {
      initialIndex = 1;
    }

    _tabController = TabController(initialIndex: initialIndex, length: 2, vsync: this);

    _tabController.addListener(() {
      // Don't clear category on swipe to avoid user frustration
      setState(() {});
    });

    if (_isEditing) {
      final tx = widget.transactionToEdit!;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _notesController.text = tx.notes ?? '';
      _selectedDate = tx.date;

      if (tx.imagePaths != null) {
        for (var path in tx.imagePaths!) {
          _imageFiles.add(XFile(path));
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<TransactionProvider>(context, listen: false);
        try {
          _selectedAccount = provider.accounts.firstWhere((acc) => acc.id == tx.account.id);
        } catch (e) {
          if (provider.accounts.isNotEmpty) _selectedAccount = provider.accounts.first;
        }
        try {
          _selectedCategory = provider.categories.firstWhere((cat) => cat.id == tx.category.id);
        } catch (e) {}
        setState(() {});
      });

    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<TransactionProvider>(context, listen: false);
        if (provider.accounts.isNotEmpty) {
          setState(() { _selectedAccount = provider.accounts.first; });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (Platform.isAndroid) {
      await Permission.photos.request();
      await Permission.storage.request();
    }
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() { _imageFiles.add(pickedFile); });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () { _pickImage(ImageSource.gallery); Navigator.of(ctx).pop(); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () { _pickImage(ImageSource.camera); Navigator.of(ctx).pop(); },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101)
    );
    if (picked != null && picked != _selectedDate) { setState(() { _selectedDate = picked; }); }
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return; // Prevent double taps

    // 1. Validate Form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Validate Dropdowns
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Category.')));
      return;
    }
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an Account.')));
      return;
    }

    // 3. Validate User Session
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session Error. Please login again.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 4. Safe Amount Parsing (Handle commas and dots)
      String amountText = _amountController.text.replaceAll(',', ''); // Remove commas
      final amount = double.tryParse(amountText);

      if (amount == null) {
        throw Exception("Invalid amount format");
      }

      final transactionType = _tabController.index == 0 ? TransactionType.expense : TransactionType.income;
      final imagePaths = _imageFiles.map((file) => file.path).toList();

      final transaction = TransactionModel(
        id: _isEditing ? widget.transactionToEdit!.id : const Uuid().v4(),
        userId: user.id,
        amount: amount,
        type: transactionType,
        category: _selectedCategory!,
        account: _selectedAccount!,
        date: _selectedDate,
        notes: _notesController.text,
        imagePaths: imagePaths,
      );

      final provider = Provider.of<TransactionProvider>(context, listen: false);

      if (_isEditing) {
        // Delete old, add new (simplest way to handle balance updates)
        await provider.deleteTransaction(widget.transactionToEdit!.id);
        await provider.addTransaction(transaction);
      } else {
        await provider.addTransaction(transaction);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction Saved!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        bottom: TabBar(controller: _tabController, tabs: const [ Tab(text: 'Expense'), Tab(text: 'Income'), ]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionForm(context, TransactionType.expense),
          _buildTransactionForm(context, TransactionType.income),
        ],
      ),
    );
  }

  Widget _buildTransactionForm(BuildContext context, TransactionType type) {
    final provider = Provider.of<TransactionProvider>(context);
    final categories = provider.getCategoriesByType(type);
    final accounts = provider.accounts;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Input
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder(), prefixText: "Rp "),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter amount';
                if (double.tryParse(val.replaceAll(',', '')) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Account Dropdown
            DropdownButtonFormField<Account>(
              value: _selectedAccount,
              hint: const Text('Select Account'),
              items: accounts.map((acc) => DropdownMenuItem(value: acc, child: Text(acc.name))).toList(),
              onChanged: (val) => setState(() => _selectedAccount = val),
              decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Category Grid
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory?.id == category.id;
                return GestureDetector(
                  onTap: () { setState(() { _selectedCategory = category; }); },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? category.color.withOpacity(0.4) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: category.color, width: 2) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(category.icon, color: category.color),
                        const SizedBox(height: 4),
                        Text(category.name, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Date Picker Row
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold))),
                TextButton(onPressed: () => _selectDate(context), child: const Text('Change')),
              ],
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder())),
            const SizedBox(height: 24),

            // Photos Section
            const Text('Photos', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showImageSourceActionSheet(context),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageFiles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(_imageFiles[index].path), width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () { setState(() { _imageFiles.removeAt(index); }); },
                                  child: Container(
                                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _isSaving ? Colors.grey : Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}