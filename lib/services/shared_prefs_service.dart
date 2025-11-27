import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_model.dart';
import 'dart:convert';

class SharedPrefsService {
  static const String _themeKey = 'isDarkTheme';
  static const String _lastViewedKey = 'lastViewedMovieId';
  static const String _favoritesKey = 'favoriteMovies';

  static Future<bool> getIsDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  static Future<void> setIsDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  static Future<int?> getLastViewedMovieId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastViewedKey);
  }

  static Future<void> setLastViewedMovieId(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastViewedKey, movieId);
  }

  static Future<void> addToFavorites(FavoriteMovie movie) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    if (!favorites.any((fav) => fav.id == movie.id)) {
      favorites.add(movie);
      await _saveFavoritesList(favorites);
    }
  }

  static Future<List<FavoriteMovie>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);

    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => FavoriteMovie.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> updateFavorite(FavoriteMovie updatedMovie) async {
    final favorites = await getFavorites();
    final index = favorites.indexWhere((fav) => fav.id == updatedMovie.id);
    if (index != -1) {
      favorites[index] = updatedMovie;
      await _saveFavoritesList(favorites);
    }
  }

  static Future<void> removeFromFavorites(int movieId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((fav) => fav.id == movieId);
    await _saveFavoritesList(favorites);
  }

  static Future<bool> isFavorite(int movieId) async {
    final favorites = await getFavorites();
    return favorites.any((fav) => fav.id == movieId);
  }

  static Future<void> _saveFavoritesList(List<FavoriteMovie> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = favorites.map((movie) => movie.toJson()).toList();
    await prefs.setString(_favoritesKey, json.encode(jsonList));
  }
}
