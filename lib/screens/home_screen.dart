import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../utils/helpers.dart';
import '../widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => HomeScreenState();  // ← UBAH NAMA!
}

// ============================================================
// UBAH NAMA CLASS STATE MENJADI HomeScreenState
// ============================================================
class HomeScreenState extends State<HomeScreen> {  // ← TANPA UNDERSCORE!
  List<TransactionModel> transactions = [];
  String selectedCategory = 'Makanan';
  String selectedPayment = 'Tunai';  // ← TAMBAHKAN INI!
  final List<String> paymentMethods = ['Tunai', 'QRIS', 'Transfer Bank', 'Debit', 'Kredit'];  // ← TAMBAHKAN INI!
  double diskon = 0;
  double pajak = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  final List<String> categories = ['Makanan', 'Minuman', 'Snack', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSettings();
  }

  Future<void> _loadData() async {
    final data = await DatabaseService.getTransactions();
    setState(() {
      transactions = data;
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      diskon = prefs.getDouble('diskon') ?? 0;
      pajak = prefs.getDouble('pajak') ?? 0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('diskon', diskon);
    await prefs.setDouble('pajak', pajak);
  }

  int get totalItems {
    int total = 0;
    for (var item in transactions) {
      total += item.qty;
    }
    return total;
  }

  double get totalAmount {
    double total = 0;
    for (var item in transactions) {
      total += item.total;
    }
    return total;
  }

  double get totalAfterDiscount {
    return totalAmount - (totalAmount * diskon / 100);
  }

  double get totalAfterTax {
    return totalAfterDiscount + (totalAfterDiscount * pajak / 100);
  }

  // ============================================================
  // FUNGSI PUBLIK UNTUK DIPANGGIL DARI LUAR (main.dart)
  // ============================================================
  void printReceipt() {
    _printReceipt();
  }

  // ============================================================
  // FUNGSI PRIVATE CETAK STRUK
  // ============================================================
  void _printReceipt() async {
    if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Tidak ada transaksi untuk dicetak')),
        );
        return;
    }

    final items = transactions.map((item) {
        return {
        'name': item.name,
        'qty': item.qty,
        'price': item.price,
        'total': item.total,
        };
    }).toList();

    double subtotal = totalAmount;
    double total = totalAfterTax;
    String invoice = transactions.last.invoice;
    String date = Helpers.formatDate(transactions.last.date);
    String cashier = 'Admin';

    await Helpers.printReceipt(
        context: context,  // ← KIRIM CONTEXT!
        invoice: invoice,
        date: date,
        items: items,
        subtotal: subtotal,
        diskon: diskon,
        pajak: pajak,
        total: total,
        paymentMethod: selectedPayment,
        cashier: cashier,
    );
  }

  void _addTransaction() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final qty = int.tryParse(_qtyController.text.trim());

    if (name.isEmpty || price == null || qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Isi data dengan benar!')),
      );
      return;
    }

    final newTransaction = TransactionModel(
      name: name,
      price: price,
      qty: qty,
      total: price * qty,
      category: selectedCategory,
      invoice: Helpers.generateInvoiceNumber(transactions.length),
      date: DateTime.now().toIso8601String(),
    );

    setState(() {
      transactions.add(newTransaction);
    });

    DatabaseService.addTransaction(newTransaction);
    _clearForm();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ $name berhasil ditambahkan!')),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _qtyController.clear();
  }
    // ============================================================
    // EDIT TRANSAKSI
    // ============================================================
    void _editTransaction(int index) {
    final item = transactions[index];
    
    _nameController.text = item.name;
    _priceController.text = item.price.toString();
    _qtyController.text = item.qty.toString();
    selectedCategory = item.category;
    
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
        title: const Text('Edit Transaksi'),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Item'),
            ),
            const SizedBox(height: 8),
            TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga'),
            ),
            const SizedBox(height: 8),
            TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Qty'),
            ),
            ],
        ),
        actions: [
            TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
            ),
            TextButton(
            onPressed: () {
                final name = _nameController.text.trim();
                final price = double.tryParse(_priceController.text.trim());
                final qty = int.tryParse(_qtyController.text.trim());
                
                if (name.isEmpty || price == null || qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Isi data dengan benar!')),
                );
                return;
                }
                
                setState(() {
                transactions[index] = TransactionModel(
                    name: name,
                    price: price,
                    qty: qty,
                    total: price * qty,
                    category: selectedCategory,
                    invoice: item.invoice,
                    date: item.date,
                );
                });
                
                DatabaseService.saveTransactions(transactions);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Transaksi berhasil diupdate!')),
                );
            },
            child: const Text('Simpan'),
            ),
        ],
      ),
    );
 }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Form
          Card(
            elevation: 8,
            shadowColor: Colors.blue.shade200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: '📦 Nama Item',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '💰 Harga',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _qtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '🔢 Qty',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                      dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                category == 'Makanan'
                                    ? Icons.restaurant
                                    : category == 'Minuman'
                                        ? Icons.local_drink
                                        : category == 'Snack'
                                            ? Icons.fastfood
                                            : Icons.category,
                                color: Colors.blue,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '📂 Kategori',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  
                     // ============================================================
                    // TAMBAHKAN DROPDOWN PEMBAYARAN DI SINI!
                    // ============================================================
                    Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        ),
                    ),
                    child: DropdownButtonFormField<String>(
                        value: selectedPayment,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                        dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
                        style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        ),
                        items: paymentMethods.map((method) {
                        return DropdownMenuItem(
                            value: method,
                            child: Row(
                            children: [
                                Icon(
                                method == 'Tunai'
                                    ? Icons.money
                                    : method == 'QRIS'
                                        ? Icons.qr_code
                                        : method == 'Transfer Bank'
                                            ? Icons.account_balance
                                            : method == 'Debit'
                                                ? Icons.credit_card
                                                : Icons.credit_card,
                                color: Colors.blue,
                                size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(method),
                            ],
                            ),
                        );
                        }).toList(),
                        onChanged: (value) {
                        setState(() {
                            selectedPayment = value!;
                        });
                        },
                        decoration: InputDecoration(
                        labelText: '💳 Metode Pembayaran',
                        labelStyle: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                        ),
                      ),
                    ),
                 ),

                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Tambah Transaksi',
                    onPressed: _addTransaction,
                    icon: Icons.add,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Diskon & Pajak
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Diskon (%)'),
                            Slider(
                              value: diskon,
                              min: 0,
                              max: 100,
                              onChanged: (value) {
                                setState(() {
                                  diskon = value;
                                });
                                _saveSettings();
                              },
                            ),
                            Text('${diskon.toStringAsFixed(0)}%'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pajak (%)'),
                            Slider(
                              value: pajak,
                              min: 0,
                              max: 20,
                              onChanged: (value) {
                                setState(() {
                                  pajak = value;
                                });
                                _saveSettings();
                              },
                            ),
                            Text('${pajak.toStringAsFixed(0)}%'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Setelah Diskon & Pajak:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          Helpers.formatCurrency(totalAfterTax),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistik
          Row(
            children: [
              Expanded(
                child: Card(
                  color: isDark ? Colors.grey.shade800 : Colors.blue.shade50,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('📊 Total Item',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text('$totalItems',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  color: isDark ? Colors.grey.shade800 : Colors.green.shade50,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('💰 Total',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(Helpers.formatCurrency(totalAmount),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}