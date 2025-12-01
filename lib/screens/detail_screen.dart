import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/movie_model.dart';
import '../models/cast_model.dart';
import '../models/favorite_model.dart';
import '../models/video_model.dart';
import '../services/api_services.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import '../services/shared_prefs_service.dart';
import '../widgets/cast_card.dart';
import '../widgets/youtube_player_widget.dart';

class DetailScreen extends StatefulWidget {
  final int movieId;
  final String? movieTitle;

  const DetailScreen({
    Key? key,
    required this.movieId,
    this.movieTitle,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Map<String, dynamic>> _movieDetails;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _movieDetails = _apiService.getMovieDetails(widget.movieId);
    _loadLastViewed();
  }

  void _loadLastViewed() async {
    await SharedPrefsService.setLastViewedMovieId(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199EF3);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }

          if (snapshot.hasError) {
            return _buildErrorState(context);
          }

          if (!snapshot.hasData) {
            return _buildNoDataState(context);
          }

          final movie = snapshot.data!['movie'] as Movie;
          final cast = snapshot.data!['cast'] as List<Cast>;
          final youtubeTrailer = movie.youtubeTrailer;

          return CustomScrollView(
            slivers: [
              // Netflix Style App Bar with Backdrop
              SliverAppBar(
                expandedHeight: 400,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Backdrop Image
                      movie.backdropPath != null
                          ? Image.network(
                              'https://image.tmdb.org/t/p/w780${movie.backdropPath}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: Icon(Icons.movie,
                                        size: 80, color: Colors.white54),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(Icons.movie,
                                    size: 80, color: Colors.white54),
                              ),
                            ),

                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withOpacity(0.9),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Consumer<FavoriteProvider>(
                      builder: (context, favoriteProvider, child) {
                        final authProvider = context.read<AuthProvider>();

                        if (!authProvider.isLoggedIn) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.favorite_border,
                                  color: Colors.white),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please login to add favorites'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          );
                        }

                        final isFavorite =
                            favoriteProvider.isMovieFavorite(movie.id);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : const Color.fromARGB(255, 152, 57, 51),
                            ),
                            onPressed: () {
                              final favoriteMovie =
                                  FavoriteMovie.fromMovie(movie);
                              favoriteProvider.toggleFavorite(favoriteMovie);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite
                                        ? 'Removed from favorites'
                                        : 'Added to favorites',
                                    style:
                                        const TextStyle(fontFamily: 'Poppins'),
                                  ),
                                  backgroundColor: primaryColor,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Movie Details Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              movie.title,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Rating Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: primaryColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    size: 20, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  movie.voteAverage.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Release Date
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: primaryColor),
                          const SizedBox(width: 6),
                          Text(
                            movie.releaseDate.isNotEmpty
                                ? movie.releaseDate
                                : 'Coming Soon',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // TRAILER SECTION
                      if (youtubeTrailer != null) ...[
                        YoutubePlayerWidget(video: youtubeTrailer),
                        const SizedBox(height: 32),
                      ] else ...[
                        // Placeholder jika tidak ada trailer
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.videocam_off, color: primaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No trailer available for this movie',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Overview Section
                      Text(
                        'Overview',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        movie.overview.isNotEmpty
                            ? movie.overview
                            : 'No overview available.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          height: 1.6,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Cast Section
                      if (cast.isNotEmpty) ...[
                        Text(
                          'Cast',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: cast.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  right: index == cast.length - 1 ? 0 : 12,
                                ),
                                child: CastCard(cast: cast[index]),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          expandedHeight: 400,
          flexibleSpace: Placeholder(),
          pinned: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 30,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Container(
                  width: 100,
                  height: 20,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 24),
                // Shimmer untuk trailer
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: 80,
                  height: 25,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                ...List.generate(
                    4,
                    (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.grey[300],
                          ),
                        )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Movie Details',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {
              _movieDetails = _apiService.getMovieDetails(widget.movieId);
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF199EF3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Movie Data',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
