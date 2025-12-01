import 'video_model.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final double voteAverage;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final List<Video>? videos;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    this.videos,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      voteAverage: (json['vote_average'] as num).toDouble(),
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'],
      videos: json['videos'] != null && json['videos']['results'] != null
          ? (json['videos']['results'] as List<dynamic>)
              .map((v) => Video.fromJson(v as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  String get fullPosterUrl {
    return posterPath != null
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
        : 'https://via.placeholder.com/500x750?text=No+Image';
  }

  Video? get youtubeTrailer {
    if (videos == null || videos!.isEmpty) return null;
    // try to find an official YouTube trailer; fall back to any YouTube video or the first video
    try {
      return videos!.firstWhere(
        (video) => video.type == 'Trailer' && video.site == 'YouTube',
      );
    } catch (_) {
      try {
        return videos!.firstWhere((video) => video.site == 'YouTube');
      } catch (_) {
        return videos!.first;
      }
    }
  }
}
