import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';
import '../screens/detail_screen.dart';
import '../screens/search_screen.dart';
import '../models/movie_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadAllMovies();
    });
    _startAutoPlay();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = _currentPage + 1;
        final itemCount = context.read<MovieProvider>().nowPlayingMovies.length;
        if (nextPage >= (itemCount > 5 ? 5 : itemCount)) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF199EF3);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.isLoading) {
            return _buildShimmerLoading();
          }

          if (movieProvider.error != null) {
            return _buildErrorState(movieProvider, context);
          }

          return CustomScrollView(
            slivers: [
              // Netflix Style App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'SanzFlix',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SearchScreen()),
                      );
                    },
                  ),
                ],
              ),

              // Hero Carousel Section
              if (movieProvider.nowPlayingMovies.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildHeroCarousel(
                      movieProvider.nowPlayingMovies, context),
                ),

              // Movie Sections
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildMovieSection(
                    context,
                    'Trending Now',
                    movieProvider.popularMovies,
                  ),
                  const SizedBox(height: 32),
                  _buildMovieSection(
                    context,
                    'Top Rated',
                    movieProvider.topRatedMovies,
                  ),
                  const SizedBox(height: 32),
                  _buildMovieSection(
                    context,
                    'Coming Soon',
                    movieProvider.upcomingMovies,
                  ),
                  const SizedBox(height: 32),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroCarousel(List<Movie> movies, BuildContext context) {
    final carouselMovies = movies.take(5).toList();

    return Column(
      children: [
        SizedBox(
          height: 500,
          child: PageView.builder(
            controller: _pageController,
            itemCount: carouselMovies.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final movie = carouselMovies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        movieId: movie.id,
                        movieTitle: movie.title,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Movie Backdrop
                        movie.backdropPath != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w780${movie.backdropPath}',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: Icon(Icons.movie,
                                          size: 50, color: Colors.white54),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Icon(Icons.movie,
                                      size: 50, color: Colors.white54),
                                ),
                              ),

                        // Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),

                        // Movie Info
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 20, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    movie.voteAverage.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    movie.releaseDate.isNotEmpty
                                        ? movie.releaseDate.substring(0, 4)
                                        : 'Coming Soon',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Carousel Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            carouselMovies.length,
            (index) => Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? const Color(0xFF199EF3)
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieSection(
      BuildContext context, String title, List<Movie> movies) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Container(
                  width: 120,
                  margin: EdgeInsets.only(
                    right: index == movies.length - 1 ? 0 : 12,
                  ),
                  child: MovieCard(movie: movie),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('SanzFlix'),
        ),
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Container(
                  height: 500,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 32),
                ...List.generate(
                    3,
                    (index) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 150,
                                height: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (context, index) => Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(MovieProvider movieProvider, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Movies',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              movieProvider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => movieProvider.loadAllMovies(),
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
}
