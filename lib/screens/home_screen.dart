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
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
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

  void _navigateToSearch() {
    if (_searchController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SearchScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SearchScreen(),
        ),
      );
    }
  }

  // CUSTOM LOGO WIDGET - Ganti dengan logo vector lu
  Widget _buildCustomLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // LOGO CONTAINER - Ganti dengan asset vector lu
        Container(
          width: 32, // Sesuaikan dengan ukuran logo lu
          height: 32,
          decoration: const BoxDecoration(
            // === GANTI DENGAN LOGO LU ===
            image: DecorationImage(
              image: AssetImage('assets/images/vector.png'), // Path logo lu
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // APP NAME
        // Text(
        //   'anzFlix',
        //   style: TextStyle(
        //     fontFamily: 'Poppins',
        //     fontSize: 20,
        //     fontWeight: FontWeight.w700,
        //     color: const Color(0xFF199EF3),
        //   ),
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199EF3);

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
              // App Bar dengan Custom Logo
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                title: _buildCustomLogo(), // Custom logo di sini
                actions: [
                  // Notification Icon
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications feature coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // SEARCH BAR SECTION - di atas carousel
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildSearchBar(context),
                ),
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
                    'Top 10 in Indonesia Today',
                    movieProvider.popularMovies.take(10).toList(),
                    showBackgroundRank: true,
                  ),
                  const SizedBox(height: 32),
                  _buildMovieSection(
                    context,
                    'Top Rated Movies',
                    movieProvider.topRatedMovies.take(10).toList(),
                    showRank: true,
                  ),
                  const SizedBox(height: 32),
                  _buildMovieSection(
                    context,
                    'Coming Soon',
                    movieProvider.upcomingMovies,
                    showRank: false,
                    showBackgroundRank: false,
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

  // SEARCH BAR WIDGET - Netflix Style
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for movies, TV shows...',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.8),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
          alignLabelWithHint: true,
          isDense: true,
        ),
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
        textAlignVertical: TextAlignVertical.center,
        onTap: _navigateToSearch,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _navigateToSearch();
          }
        },
      ),
    );
  }

  Widget _buildHeroCarousel(List<Movie> movies, BuildContext context) {
    final carouselMovies = movies.take(5).toList();

    return Column(
      children: [
        const SizedBox(height: 8), // Sedikit spacing dari search bar
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
                    ? const Color.fromARGB(255, 39, 82, 129)
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMovieSection(
    BuildContext context,
    String title,
    List<Movie> movies, {
    bool showRank = false,
    bool showBackgroundRank = false,
  }) {
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: showBackgroundRank ? 180 : 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Container(
                  width: showBackgroundRank ? 140 : 120,
                  margin: EdgeInsets.only(
                    right: index == movies.length - 1 ? 0 : 12,
                  ),
                  child: MovieCard(
                    movie: movie,
                    rank: (showRank || showBackgroundRank) ? index + 1 : null,
                    showRank: showRank,
                    showBackgroundRank: showBackgroundRank,
                  ),
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
        // App Bar Shimmer dengan Custom Logo
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 80,
                height: 20,
                color: Colors.grey[300],
              ),
            ],
          ),
          actions: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.all(8),
              color: Colors.grey[300],
            ),
          ],
        ),

        // Search Bar Shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        // Carousel Shimmer
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(MovieProvider movieProvider, BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
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
              color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => movieProvider.loadAllMovies(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 243, 25, 25),
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
