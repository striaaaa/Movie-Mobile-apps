import 'package:dio/dio.dart';
import 'package:movie_browser_app/models/favorite_model.dart';
import 'package:movie_browser_app/services/shared_prefs_service.dart';
// import 'package:movie_browser_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie_model.dart';
import '../models/userModel.dart';
import '../models/cast_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _tmdbBaseUrl = 'https://api.themoviedb.org/3';
  // final String _watchlistBaseUrl = 'http://127.0.0.1:8000/api/';
  // final String _watchlistBaseUrl = 'http://192.168.1.2:8000/api';
  final String _watchlistBaseUrl =
      'https://nonconstraining-unimitative-tia.ngrok-free.dev/api';
  final String _apiKey = 'dd04310045c6e1d96bd35eaa2dc8e64e';

  ApiService() {
    // _dio.options.baseUrl = _tmdbBaseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.queryParameters['api_key'] = _apiKey;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          // final token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvYXBpL2xvZ2luIiwiaWF0IjoxNzY0NTgxNDE3LCJleHAiOjE3NjQ1ODUwMTcsIm5iZiI6MTc2NDU4MTQxNywianRpIjoia1J0dEszeFhqdWtaRkcwUCIsInN1YiI6IjIiLCJwcnYiOiIyM2JkNWM4OTQ5ZjYwMGFkYjM5ZTcwMWM0MDA4NzJkYjdhNTk3NmY3In0.81k8atbws-eJOKOJ7axi1vyzCoyyCNpL2bW_T5Qdtlw';

          final token = await SharedPrefsService.getAccessToken();
          final refresh = await SharedPrefsService.getRefreshToken();

          print(token);
          print(refresh);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioError error, handler) async {
          if (error.response?.statusCode == 401) {
            // final success = true;
            final success = await _refreshToken();
            if (success) {
              final prefs = await SharedPreferences.getInstance();
              final newToken = prefs.getString('access_token');
              final requestOptions = error.requestOptions;

              final response = await _dio.request(
                requestOptions.path,
                options: Options(
                  method: requestOptions.method,
                  headers: {
                    ...requestOptions.headers,
                    'Authorization': 'Bearer $newToken',
                  },
                ),
                data: requestOptions.data,
                queryParameters: requestOptions.queryParameters,
              );
              return handler.resolve(response);
            }
          }
          handler.next(error);
        },
      ),
    );
  }
  Future<User?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_watchlistBaseUrl/login',
        data: {'email': email, 'password': password},
        options: Options(
          headers: {
            "ngrok-skip-browser-warning": "69420",
          },
        ),
      );

      final data = response.data;
//  print(data);
      if (data['access_token'] != null && data['refresh_token'] != null) {
        await SharedPrefsService.setAccessToken(data['access_token']);
        await SharedPrefsService.setRefreshToken(data['refresh_token']);
      }

      final userJson = data['user'] ??
          {
            'id': int.parse(data['sub'] ?? '0'),
            'name': '',
            'email': email,
            'created_at': DateTime.now().toIso8601String()
          };

      final user = User.fromJson(userJson);

      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<User?> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        '$_watchlistBaseUrl/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
        options: Options(
          headers: {
            "ngrok-skip-browser-warning": "69420",
          },
        ),
      );

      final data = response.data;

      if (data['access_token'] != null && data['refresh_token'] != null) {
        final token = await SharedPrefsService.getAccessToken();
        final refresh = await SharedPrefsService.getRefreshToken();
        print(token);
        print(refresh);
        await SharedPrefsService.setAccessToken(data['access_token']);
        await SharedPrefsService.setRefreshToken(data['refresh_token']);

        print(token);
        print(refresh);
      }

      final userJson = data['user'] ??
          {
            'id': int.parse(data['sub'] ?? '0'),
            'name': name,
            'email': email,
            'created_at': DateTime.now().toIso8601String(),
          };
      final user = User.fromJson(userJson);
      // await SharedPrefsService.setCurrentUser(user);

      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await SharedPrefsService.removeAccessToken();
    await SharedPrefsService.removeRefreshToken();
  }

  // Dapatkan current user
  // Future<User?> getCurrentUser() async {
  //   final userJson = await SharedPrefsService.getString(_currentUserKey);
  //   if (userJson != null) {
  //     return User.fromJson(json.decode(userJson));
  //   }
  //   return null;
  // }

  // // Dapatkan token
  // Future<String?> getAccessToken() async {
  //   return await SharedPrefsService.getString(_accessTokenKey);
  // }

  // Future<String?> getRefreshToken() async {
  //   return await SharedPrefsService.getString(_refreshTokenKey);
  // }

  // Refresh token dari SharedPreferences
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ' https://nonconstraining-unimitative-tia.ngrok-free.dev/api/refresh',
        data: {'refresh_token': refreshToken},
      );
      // final response = await _dio.post(
      //   'http://127.0.0.1:8000/api/refresh',
      //   data: {'refresh_token': refreshToken},
      // );

      // Update token baru di SharedPreferences
      await prefs.setString('access_token', response.data['access_token']);
      await prefs.setString('refresh_token', response.data['refresh_token']);

      return true;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      return false;
    }
  }

  Future<List<Movie>> getNowPlayingMovies() async {
    try {
      final response = await _dio.get('$_tmdbBaseUrl/movie/now_playing');
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load now playing movies: $e');
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await _dio.get('$_tmdbBaseUrl/movie/popular');
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load popular movies: $e');
    }
  }

  Future<User?> getCurrentUserLogin() async {
    try {
      final response = await _dio.get('$_watchlistBaseUrl/userLogin');
      final data = response.data;
      print(data);
      if (data != null) {
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load current user: $e');
    }
  }

  Future<List<Movie>> getTopRatedMovies() async {
    try {
      final response = await _dio.get('$_tmdbBaseUrl/movie/top_rated');
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load top rated movies: $e');
    }
  }

  Future<List<Movie>> getUpcomingMovies() async {
    try {
      final response = await _dio.get('$_tmdbBaseUrl/movie/upcoming');
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load upcoming movies: $e');
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    try {
      final movieResponse = await _dio.get('$_tmdbBaseUrl/movie/$movieId');
      final creditsResponse =
          await _dio.get('$_tmdbBaseUrl/movie/$movieId/credits');
      final videosResponse =
          await _dio.get('$_tmdbBaseUrl/movie/$movieId/videos');

      final movieData = movieResponse.data;
      movieData['videos'] = videosResponse.data;

      final movie = Movie.fromJson(movieData);
      final cast = (creditsResponse.data['cast'] as List)
          .map((json) => Cast.fromJson(json))
          .toList();

      return {'movie': movie, 'cast': cast};
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _dio.get(
        '$_tmdbBaseUrl/search/movie',
        queryParameters: {'query': query},
      );
      final results = response.data['results'] as List;
      return results.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  // Future<Response> toggleAddFavorite(String userId, String movieId) async {
  //   return _dio.post('$_watchlistBaseUrl/watchlist/toggle', data: {
  //     'user_id': userId,
  //     'movie_api_id': movieId,
  //   });
  // }
  // Future<Response> addToFavorite(String userId, String movieId) async {
  //   return _dio.post('$_watchlistBaseUrl/watchlist/add', data: {
  //     'user_id': userId,
  //     'movie_api_id': movieId,
  //   });
  // }
  Future<List<FavoriteMovie>> getFavoritesByUser(int userId) async {
    try {
      final response = await _dio.get(
        '$_watchlistBaseUrl/watchlist/$userId',
        options: Options(headers: {
          "ngrok-skip-browser-warning": "69420",
        }),
      );

      final data = response.data;

      if (data == null || data == null) {
        return [];
      }

      final favList =
          (data as List).map((json) => FavoriteMovie.fromJson(json)).toList();

      return favList;
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }

  Future<Response> toggleAddFavorite(int? userId, String movieId) async {
    try {
      return await _dio.post(
        '$_watchlistBaseUrl/watchlist/toggle',
        data: {
          'user_id': userId,
          'movie_api_id': movieId,
        },
        options: Options(
          headers: {
            "ngrok-skip-browser-warning": "69420",
          },
        ),
      );
    } catch (e) {
      throw Exception("Failed API add favorite: $e");
    }
  }

  Future<FavoriteMovie?> updateFavorite(
    int userId,
    int movieApiId,
    FavoriteMovie updatedMovie,
  ) async {
    try {
      final payload = {
        "user_id": userId, // ⬅ tambahkan di sini
        "movie_api_id": movieApiId, // ⬅ wajib supaya BE bisa find watchlist
        ...updatedMovie.toJson(), // merge json movie
      };
      final response = await _dio.put(
        '$_watchlistBaseUrl/watchlist/update/$movieApiId',
        data: payload,
        // data: updatedMovie.toJson(),
        options: Options(headers: {
          "ngrok-skip-browser-warning": "69420",
        }),
      );
      final data = response.data;
      if (data == null || data == null) {
        return null;
      }
      // API balikin {"message": "...", "data": {...}}
      final updatedJson = data;

      return FavoriteMovie.fromJson(updatedJson);
    } catch (e) {
      throw Exception('Failed to update favorite: $e');
    }
  }

  Future<Response> getWatchlist(String userId) async {
    return _dio.get('$_watchlistBaseUrl/watchlist/',
        queryParameters: {'user_id': userId});
  }
}
