import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'wishlist_store.dart';

class AuthStore {
  AuthStore._();

  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
  static final ValueNotifier<String?> token = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> userName = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> userEmail = ValueNotifier<String?>(null);
  static final ValueNotifier<int?> userId = ValueNotifier<int?>(null);
  static final ValueNotifier<String?> userRole = ValueNotifier<String?>(null);

  static bool get isAdmin => userRole.value == 'admin';

  // Inisialisasi session dari penyimpanan lokal HP
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString('auth_token');
    userName.value = prefs.getString('user_name');
    userEmail.value = prefs.getString('user_email');
    userId.value = prefs.getInt('user_id');
    userRole.value = prefs.getString('user_role');
    isLoggedIn.value = token.value != null;
    
    // Sinkronisasi data wishlist
    await WishlistStore.loadFromBackend();
  }

  // Menyimpan session setelah login/register sukses
  static Future<void> saveSession({
    required String authToken,
    required String name,
    required String email,
    required int id,
    String role = 'user',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', authToken);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setInt('user_id', id);
    await prefs.setString('user_role', role);

    token.value = authToken;
    userName.value = name;
    userEmail.value = email;
    userId.value = id;
    userRole.value = role;
    isLoggedIn.value = true;

    // Sinkronisasi data wishlist
    await WishlistStore.loadFromBackend();
  }

  // Menghapus session saat logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_id');
    await prefs.remove('user_role');

    token.value = null;
    userName.value = null;
    userEmail.value = null;
    userId.value = null;
    userRole.value = null;
    isLoggedIn.value = false;

    // Bersihkan wishlist
    WishlistStore.ids.value = {};
  }
}
