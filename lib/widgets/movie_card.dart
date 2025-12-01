import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie_model.dart';
import '../screens/detail_screen.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final int? rank; // Tambah parameter rank
  final bool showRank; // Flag untuk rank badge kecil
  final bool showBackgroundRank; // Flag untuk angka besar di background

  const MovieCard({
    Key? key,
    required this.movie,
    this.onTap,
    this.rank,
    this.showRank = false,
    this.showBackgroundRank = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199EF3);

    return GestureDetector(
      onTap: onTap ??
          () {
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              if (showBackgroundRank && rank != null && rank! <= 10)
                Positioned(
                  left: -25,
                  top: 0,
                  bottom: 0,
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                        stops: const [0.3, 0.8],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Container(
                      width: 120,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 130,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.4),
                          height: 0.8,
                          letterSpacing: -8,
                        ),
                      ),
                    ),
                  ),
                ),
              // Movie Poster
              CachedNetworkImage(
                imageUrl: movie.fullPosterUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.movie, color: Colors.white54),
                  ),
                ),
              ),

              // Gradient Overlay - lebih gelap kalo ada background rank
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(showBackgroundRank ? 0.9 : 0.8),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // TOP 10 BADGE KECIL (di pojok kiri atas)
              if (showRank &&
                  rank != null &&
                  rank! <= 10 &&
                  !showBackgroundRank)
                Positioned(
                  top: 8,
                  left: 8,
                  child: _buildRankBadge(rank!),
                ),

              // Movie Info at Bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(showBackgroundRank ? 16 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: showBackgroundRank ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: showBackgroundRank ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            movie.releaseDate.isNotEmpty
                                ? movie.releaseDate.substring(0, 4)
                                : 'TBA',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // BACKGROUND RANK WITH OUTLINE EFFECT
              if (showBackgroundRank && rank != null && rank! <= 10)
                Positioned(
                  left: -5,
                  top: 50,
                  bottom: 0,
                  child: Stack(
                    children: [
                      // Outline shadow
                      Text(
                        '$rank',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 90,
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                            ..color = Colors.black.withOpacity(0.3),
                          height: 0.8,
                        ),
                      ),
                      // Main number
                      Text(
                        '$rank',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 90,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.25),
                          height: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Netflix Style Rank Badge (untuk badge kecil)
  Widget _buildRankBadge(int rank) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF199EF3), // Netflix red
            Color(0xFF199EF3), // Darker red
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
