import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction_model.dart';

class DatabaseService {
  static const String _keyTransactions = 'transactions';

  static Future<List<TransactionModel>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_keyTransactions);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded
            .map((item) => TransactionModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error loading transactions: $e');
    }
    return [];
  }

  static Future<void> saveTransactions(List<TransactionModel> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonData = jsonEncode(
        transactions.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_keyTransactions, jsonData);
    } catch (e) {
      print('Error saving transactions: $e');
    }
  }

  static Future<void> addTransaction(TransactionModel transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  static Future<void> deleteTransaction(int index) async {
    final transactions = await getTransactions();
    if (index >= 0 && index < transactions.length) {
      transactions.removeAt(index);
      await saveTransactions(transactions);
    }
  }

  static Future<void> clearAll() async {
    await saveTransactions([]);
  }
}