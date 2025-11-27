import 'package:flutter/foundation.dart';
import '../models/favorite_model.dart';
import '../services/shared_prefs_service.dart';

class FavoriteProvider with ChangeNotifier {
  List<FavoriteMovie> _favorites = [];
  bool _isLoading = false;

  List<FavoriteMovie> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await SharedPrefsService.getFavorites();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading favorites: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFavorite(FavoriteMovie movie) async {
    await SharedPrefsService.addToFavorites(movie);
    _favorites.add(movie);
    notifyListeners();
  }

  Future<void> removeFavorite(int movieId) async {
    await SharedPrefsService.removeFromFavorites(movieId);
    _favorites.removeWhere((fav) => fav.id == movieId);
    notifyListeners();
  }

  Future<void> toggleFavorite(FavoriteMovie movie) async {
    final isCurrentlyFavorite = _favorites.any((fav) => fav.id == movie.id);

    if (isCurrentlyFavorite) {
      await removeFavorite(movie.id);
    } else {
      await addFavorite(movie);
    }
  }

  bool isMovieFavorite(int movieId) {
    return _favorites.any((fav) => fav.id == movieId);
  }

  Future<void> updateFavorite(FavoriteMovie updatedMovie) async {
    await SharedPrefsService.updateFavorite(updatedMovie);
    final index = _favorites.indexWhere((fav) => fav.id == updatedMovie.id);
    if (index != -1) {
      _favorites[index] = updatedMovie;
      notifyListeners();
    }
  }
}
