import 'package:flutter/foundation.dart';
import 'package:movie_browser_app/services/api_services.dart';
import '../models/favorite_model.dart';
import '../services/shared_prefs_service.dart';
import '../providers/auth_provider.dart';

class FavoriteProvider with ChangeNotifier {
  List<FavoriteMovie> _favorites = [];
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider;

  FavoriteProvider(this._authProvider);

  List<FavoriteMovie> get favorites => _favorites;
  bool get isLoading => _isLoading;

  // Get current user ID
  int? get _currentUserId {
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
      _favorites = await _apiService.getFavoritesByUser(_currentUserId!);
      // _favorites = await SharedPrefsService.getFavorites(_currentUserId!);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading favorites: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // // Add to favorites (CREATE)
  // Future<void> addFavorite(FavoriteMovie movie) async {
  //   if (_currentUserId == null) return;

  //   await SharedPrefsService.addToFavorites(_currentUserId!, movie);
  //   _favorites.add(movie);
  //   notifyListeners();
  // }
  Future<void> addFavorite(FavoriteMovie movie) async {
    if (_currentUserId == null) return;

    try {
      await _apiService.toggleAddFavorite(_currentUserId, movie.id.toString());
      _favorites.add(movie);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Failed to add favorite: $e");
      rethrow;
    }
  }

  // Remove from favorites (DELETE)
  Future<void> removeFavorite(int movieId) async {
    if (_currentUserId == null) return;

    try {
      await _apiService.toggleAddFavorite(_currentUserId, movieId.toString());
      // await SharedPrefsService.removeFromFavorites(_currentUserId!, movieId);
      _favorites.removeWhere((fav) => fav.id == movieId);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Failed to add favorite: $e");
      rethrow;
    }
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
  bool isMovieFavorite(int movieId) {
    return _favorites.any((fav) => fav.id == movieId);
  }

  // Update favorite (UPDATE)
  Future<void> updateFavorite(int watchListsId, FavoriteMovie updatedMovie) async {
    if (_currentUserId == null) return;

    // await SharedPrefsService.updateFavorite(_currentUserId!, updatedMovie)
    // print("sebelum API UPDATE FAVORITE");;
    await _apiService.updateFavorite(_currentUserId!, watchListsId, updatedMovie);
    final index = _favorites.indexWhere((fav) => fav.id == updatedMovie.id);
    // print("ssudah API UPDATE FAVORITE");;
    if (index != -1) {
      _favorites[index] = updatedMovie;
      print(updatedMovie);
      notifyListeners();
    }
  }

  // Clear favorites when user logs out
  void clearFavorites() {
    _favorites = [];
    notifyListeners();
  }
}
