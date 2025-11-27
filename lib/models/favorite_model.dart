import 'package:movie_browser_app/models/movie_model.dart';

class FavoriteMovie {
  final int id;
  final String title;
  final String? posterPath;
  double rating;
  final DateTime addedAt;

  FavoriteMovie({
    required this.id,
    required this.title,
    this.posterPath,
    required this.rating,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'rating': rating,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory FavoriteMovie.fromJson(Map<String, dynamic> json) {
    return FavoriteMovie(
      id: json['id'],
      title: json['title'],
      posterPath: json['posterPath'],
      rating: (json['rating'] as num).toDouble(),
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  factory FavoriteMovie.fromMovie(Movie movie) {
    return FavoriteMovie(
      id: movie.id,
      title: movie.title,
      posterPath: movie.posterPath,
      rating: movie.voteAverage,
      addedAt: DateTime.now(),
    );
  }

  FavoriteMovie copyWith({double? newRating}) {
    return FavoriteMovie(
      id: id,
      title: title,
      posterPath: posterPath,
      rating: newRating ?? rating,
      addedAt: addedAt,
    );
  }
}
