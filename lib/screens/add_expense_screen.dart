import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../boxes.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCategory = 'Groceries';
  final List<String> _categories = [
    'Groceries',
    'Bills',
    'Medicine',
    'Transport',
    'Shopping',
    'Food',
    'Rent',
    'Other',
  ];

  String _selectedPaymentMethod = 'Cash';
  final List<String> _paymentMethods = ['Cash', 'Card', 'Online'];

  DateTime _selectedDate = DateTime.now();
  final List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final e = widget.expenseToEdit!;
      _titleController.text = e.title;
      _amountController.text =
          e.amount.toStringAsFixed(0); // No decimals for int-like
      _noteController.text = e.note;
      _selectedCategory = e.category;
      _selectedPaymentMethod = e.paymentMethod;
      _selectedDate = e.date;
      _imagePaths.addAll(e.imagePaths);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _imagePaths.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;

      final expense = Expense(
        id: widget.expenseToEdit?.id ?? const Uuid().v4(),
        title: _titleController.text.isEmpty
            ? _selectedCategory
            : _titleController.text,
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        note: _noteController.text,
        paymentMethod: _selectedPaymentMethod,
        imagePaths: _imagePaths,
      );

      final box = Boxes.getExpenses();

      if (widget.expenseToEdit != null) {
        // Find key to update
        final key = box.keys.firstWhere((k) => box.get(k)?.id == expense.id,
            orElse: () => null);
        if (key != null) {
          await box.put(key, expense);
        } else {
          await box.add(expense); // Fallback
        }
      } else {
        await box.add(expense);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.expenseToEdit != null
                  ? 'Expense Updated!'
                  : 'Expense Added Successfully!')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00695C),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.expenseToEdit != null ? 'Edit Expense' : 'Add New Expense'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount Field (Big & Bold)
              // Amount Field (Big & Bold)
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                cursorColor: const Color(0xFFFF7043), // Coral cursor
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142)), // Dark text
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: 'Rs ',
                  prefixStyle: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFFFF7043), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFFFF7043), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Color(0xFFFF7043), width: 2.5),
                  ),
                  filled: true,
                  fillColor: Colors.white, // White background
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid number';
                  }
                  if (amount > 9999999) {
                    return 'Amount too large (Max 7 figures)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Expense Name
              TextFormField(
                controller: _titleController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  labelText: 'Expense Name (e.g. Milk, Taxi)',
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isDense: true,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Row: Date & Payment Method
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Payment',
                        prefixIcon: Icon(Icons.payment),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPaymentMethod,
                          isDense: true,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                          items: _paymentMethods.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedPaymentMethod = value!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Note Field
              TextFormField(
                controller: _noteController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Photo Section
              const Text(
                'Attachments',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Camera Button
                    _buildPhotoActionButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                    const SizedBox(width: 12),
                    // Gallery Button
                    _buildPhotoActionButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(width: 12),

                    // Selected Images
                    ..._imagePaths.asMap().entries.map((entry) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              image: DecorationImage(
                                image: FileImage(File(entry.value)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 16,
                            child: InkWell(
                              onTap: () => _removeImage(entry.key),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                      widget.expenseToEdit != null
                          ? 'UPDATE EXPENSE'
                          : 'SAVE EXPENSE',
                      style: const TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.grey.shade700),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}
