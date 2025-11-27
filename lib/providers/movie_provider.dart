import 'package:flutter/foundation.dart';
import 'package:movie_browser_app/services/api_services.dart';
import '../models/movie_model.dart';
import '../services/api_services.dart';

class MovieProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Movie> _nowPlayingMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _upcomingMovies = [];
  List<Movie> _searchResults = [];

  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  String? _searchError;

  List<Movie> get nowPlayingMovies => _nowPlayingMovies;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get upcomingMovies => _upcomingMovies;
  List<Movie> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  String? get searchError => _searchError;

  Future<void> loadAllMovies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadNowPlayingMovies(),
        _loadPopularMovies(),
        _loadTopRatedMovies(),
        _loadUpcomingMovies(),
      ]);
    } catch (e) {
      _error = 'Failed to load movies: $e';
      if (kDebugMode) {
        print('Error loading movies: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadNowPlayingMovies() async {
    try {
      _nowPlayingMovies = await _apiService.getNowPlayingMovies();
    } catch (e) {
      throw Exception('Failed to load now playing movies: $e');
    }
  }

  Future<void> _loadPopularMovies() async {
    try {
      _popularMovies = await _apiService.getPopularMovies();
    } catch (e) {
      throw Exception('Failed to load popular movies: $e');
    }
  }

  Future<void> _loadTopRatedMovies() async {
    try {
      _topRatedMovies = await _apiService.getTopRatedMovies();
    } catch (e) {
      throw Exception('Failed to load top rated movies: $e');
    }
  }

  Future<void> _loadUpcomingMovies() async {
    try {
      _upcomingMovies = await _apiService.getUpcomingMovies();
    } catch (e) {
      throw Exception('Failed to load upcoming movies: $e');
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchError = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchMovies(query);
    } catch (e) {
      _searchError = 'Failed to search movies: $e';
      if (kDebugMode) {
        print('Search error: $e');
      }
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchError = null;
    notifyListeners();
  }
}
