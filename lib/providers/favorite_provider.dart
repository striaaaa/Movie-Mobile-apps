import 'package:flutter/foundation.dart';
import '../models/favorite_model.dart';
import '../services/shared_prefs_service.dart';
import '../providers/auth_provider.dart';

class FavoriteProvider with ChangeNotifier {
  List<FavoriteMovie> _favorites = [];
  bool _isLoading = false;
  final AuthProvider _authProvider;

  FavoriteProvider(this._authProvider);

  List<FavoriteMovie> get favorites => _favorites;
  bool get isLoading => _isLoading;

  // Get current user ID
  String? get _currentUserId {
    return _authProvider.currentUser?.id;
  }

  // Load favorites for current user
  Future<void> loadFavorites() async {
    if (_currentUserId == null) {
      _favorites = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await SharedPrefsService.getFavorites(_currentUserId!);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading favorites: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add to favorites (CREATE)
  Future<void> addFavorite(FavoriteMovie movie) async {
    if (_currentUserId == null) return;

    await SharedPrefsService.addToFavorites(_currentUserId!, movie);
    _favorites.add(movie);
    notifyListeners();
  }

  // Remove from favorites (DELETE)
  Future<void> removeFavorite(int movieId) async {
    if (_currentUserId == null) return;

    await SharedPrefsService.removeFromFavorites(_currentUserId!, movieId);
    _favorites.removeWhere((fav) => fav.id == movieId);
    notifyListeners();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(FavoriteMovie movie) async {
    if (_currentUserId == null) return;

    final isCurrentlyFavorite = _favorites.any((fav) => fav.id == movie.id);

    if (isCurrentlyFavorite) {
      await removeFavorite(movie.id);
    } else {
      await addFavorite(movie);
    }
  }

  // Check if movie is favorite
  bool isMovieFavorite(int movieId) {
    return _favorites.any((fav) => fav.id == movieId);
  }

  // Update favorite (UPDATE)
  Future<void> updateFavorite(FavoriteMovie updatedMovie) async {
    if (_currentUserId == null) return;

    await SharedPrefsService.updateFavorite(_currentUserId!, updatedMovie);
    final index = _favorites.indexWhere((fav) => fav.id == updatedMovie.id);
    if (index != -1) {
      _favorites[index] = updatedMovie;
      notifyListeners();
    }
  }

  // Clear favorites when user logs out
  void clearFavorites() {
    _favorites = [];
    notifyListeners();
  }
}
