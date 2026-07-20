class TransactionModel {
  final String name;
  final double price;
  final int qty;
  final double total;
  final String category;
  final String invoice;
  final String date;

  TransactionModel({
    required this.name,
    required this.price,
    required this.qty,
    required this.total,
    required this.category,
    required this.invoice,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'qty': qty,
      'total': total,
      'category': category,
      'invoice': invoice,
      'date': date,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      qty: json['qty'] ?? 0,
      total: (json['total'] ?? 0).toDouble(),
      category: json['category'] ?? 'Lainnya',
      invoice: json['invoice'] ?? '',
      date: json['date'] ?? DateTime.now().toIso8601String(),
    );
  }
}