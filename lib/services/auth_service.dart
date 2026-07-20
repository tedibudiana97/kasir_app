import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUser = 'user_data';
  static const String _keyLoggedIn = 'isLoggedIn';
  
  // ============================================================
  // AKUN BAWAAN (Hardcoded)
  // ============================================================
  static const Map<String, String> _defaultUsers = {
    'admin@email.com': 'admin123',
    'user@email.com': 'user123',
    'demo@email.com': 'demo123',
  };

  // ============================================================
  // LOGIN
  // ============================================================
  static Future<bool> login(String email, String password) async {
    // Cek di akun bawaan
    if (_defaultUsers.containsKey(email) && _defaultUsers[email] == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLoggedIn, true);
      await prefs.setString('userEmail', email);
      await prefs.setString('userName', email.split('@')[0]);
      return true;
    }
    
    // Cek di akun yang terdaftar (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    final String? registeredUsers = prefs.getString(_keyUser);
    if (registeredUsers != null) {
      final Map<String, dynamic> users = Map<String, dynamic>.from(
        Map<String, dynamic>.from(
          Map<String, dynamic>.from(registeredUsers as Map)
        )
      );
      // Sederhanakan: cek email & password
      if (users.containsKey(email) && users[email] == password) {
        await prefs.setBool(_keyLoggedIn, true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userName', email.split('@')[0]);
        return true;
      }
    }
    
    return false;
  }

  // ============================================================
  // REGISTER
  // ============================================================
  static Future<bool> register(String name, String email, String password) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    
    // Simpan akun baru
    Map<String, String> users = {};
    final String? existingUsers = prefs.getString(_keyUser);
    if (existingUsers != null) {
      users = Map<String, String>.from(existingUsers as Map);
    }
    
    // Cek apakah email sudah terdaftar
    if (users.containsKey(email)) {
      return false; // Email sudah terdaftar
    }
    
    // Tambahkan akun baru
    users[email] = password;
    await prefs.setString(_keyUser, users.toString());
    
    // Auto login setelah register
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);
    
    return true;
  }

  // ============================================================
  // CEK LOGIN
  // ============================================================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove('userEmail');
    await prefs.remove('userName');
  }

  // ============================================================
  // GET CURRENT USER
  // ============================================================
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? prefs.getString('userEmail');
  }

  // ============================================================
  // GET CURRENT USER EMAIL
  // ============================================================
  static Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }
}