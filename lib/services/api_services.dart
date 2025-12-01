import 'package:dio/dio.dart';
import '../models/movie_model.dart';
import '../models/cast_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String _baseUrl2 = 'http://127.0.0.1:8000/api/watchlist/';
  final String _apiKey = 'dd04310045c6e1d96bd35eaa2dc8e64e';

  ApiService() {
    _dio.options.queryParameters['api_key'] = _apiKey;
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    try {
      final response = await _dio.get('$_baseUrl/movie/now_playing');
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load now playing movies: $e');
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await _dio.get('$_baseUrl/movie/popular');
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load popular movies: $e');
    }
  }

  Future<List<Movie>> getTopRatedMovies() async {
    try {
      final response = await _dio.get('$_baseUrl/movie/top_rated');
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load top rated movies: $e');
    }
  }

  Future<List<Movie>> getUpcomingMovies() async {
    try {
      final response = await _dio.get('$_baseUrl/movie/upcoming');
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load upcoming movies: $e');
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final movieResponse = await _dio.get('$_baseUrl/movie/$movieId');
      final creditsResponse =
          await _dio.get('$_baseUrl/movie/$movieId/credits');

      final movie = Movie.fromJson(movieResponse.data);
      final cast = (creditsResponse.data['cast'] as List)
          .map((json) => Cast.fromJson(json))
          .toList();

      return {
        'movie': movie,
        'cast': cast,
      };
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search/movie',
        queryParameters: {'query': query},
      );
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }
}
