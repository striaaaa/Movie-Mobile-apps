import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_model.dart';
import 'dart:convert';

class SharedPrefsService {
  // Auth related keys
  static const String _currentUserKey = 'currentUser';
  static const String _usersKey = 'users';

  // User-specific favorite keys will be generated dynamically
  static String _getUserFavoritesKey(String userId) {
    return 'favorites_$userId';
  }

  // === AUTH METHODS ===

  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // === THEME & SETTINGS (Global) ===

  static Future<bool> getIsDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkTheme') ?? false;
  }

  static Future<void> setIsDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', value);
  }

  static Future<int?> getLastViewedMovieId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastViewedMovieId');
  }

  static Future<void> setLastViewedMovieId(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastViewedMovieId', movieId);
  }

  // === FAVORITES (User-specific) ===

  // CREATE - Add to favorites (requires userId)
  static Future<void> addToFavorites(String userId, FavoriteMovie movie) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites(userId);

    if (!favorites.any((fav) => fav.id == movie.id)) {
      favorites.add(movie);
      await _saveFavoritesList(userId, favorites);
    }
  }

  // READ - Get all favorites (requires userId)
  static Future<List<FavoriteMovie>> getFavorites(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_getUserFavoritesKey(userId));

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => FavoriteMovie.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // UPDATE - Update favorite movie (requires userId)
  static Future<void> updateFavorite(
      String userId, FavoriteMovie updatedMovie) async {
    final favorites = await getFavorites(userId);
    final index = favorites.indexWhere((fav) => fav.id == updatedMovie.id);
    if (index != -1) {
      favorites[index] = updatedMovie;
      await _saveFavoritesList(userId, favorites);
    }
  }

  // DELETE - Remove from favorites (requires userId)
  static Future<void> removeFromFavorites(String userId, int movieId) async {
    final favorites = await getFavorites(userId);
    favorites.removeWhere((fav) => fav.id == movieId);
    await _saveFavoritesList(userId, favorites);
  }

  // CHECK - Check if movie is favorite (requires userId)
  static Future<bool> isFavorite(String userId, int movieId) async {
    final favorites = await getFavorites(userId);
    return favorites.any((fav) => fav.id == movieId);
  }

  // Helper method to save favorites list
  static Future<void> _saveFavoritesList(
      String userId, List<FavoriteMovie> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = favorites.map((movie) => movie.toJson()).toList();
    await prefs.setString(_getUserFavoritesKey(userId), json.encode(jsonList));
  }
}
