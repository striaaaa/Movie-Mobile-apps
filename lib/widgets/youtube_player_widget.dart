import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/video_model.dart';

class YoutubePlayerWidget extends StatefulWidget {
  final Video video;
  final double aspectRatio;

  const YoutubePlayerWidget({
    Key? key,
    required this.video,
    this.aspectRatio = 16 / 9,
  }) : super(key: key);

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;
  late String _videoId;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    // FIX: Gunakan key langsung daripada youtubeUrl
    _videoId = widget.video.key; // Langsung pake video.key
    _controller = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        captionLanguage: 'en',
        showLiveFullscreenButton: true,
        useHybridComposition: true,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      // Handle player state changes if needed
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video Title
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Trailer',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),

        // YouTube Player
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: YoutubePlayerBuilder(
              onExitFullScreen: () {
                // Handle exit full screen
              },
              player: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: const Color(0xFF199EF3),
                progressColors: const ProgressBarColors(
                  playedColor: Color(0xFF199EF3),
                  handleColor: Color(0xFF199EF3),
                ),
                onReady: () {
                  _isPlayerReady = true;
                },
                onEnded: (data) {
                  // Video ended
                },
              ),
              builder: (context, player) {
                return AspectRatio(
                  aspectRatio: widget.aspectRatio,
                  child: player,
                );
              },
            ),
          ),
        ),

        // Video Info
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF199EF3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.video.type.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.video.site} • ${widget.video.name}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
