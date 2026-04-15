import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../app/model.dart';
import '../app/strings.dart';

class EducationalVideosScreen extends StatefulWidget {
  const EducationalVideosScreen({super.key});

  @override
  State<EducationalVideosScreen> createState() =>
      _EducationalVideosScreenState();
}

class _EducationalVideosScreenState extends State<EducationalVideosScreen> {
  @override
  Widget build(BuildContext context) {
    final model = SustainabilityProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('watchVideo', context)),
        actions: [
          IconButton(
            onPressed: () => model.refreshEducationalVideos(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body:
          model.educationalVideos.isEmpty
              ? Center(child: Text(AppStrings.get('noResults', context)))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: model.educationalVideos.length,
                itemBuilder: (context, index) {
                  return _VideoCard(video: model.educationalVideos[index]);
                },
              ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  const _VideoCard({required this.video});

  final EducationalVideo video;

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isPlayerVisible = false;

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    );
    await _videoPlayerController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
    );
    setState(() => _isPlayerVisible = true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child:
                _isPlayerVisible && _chewieController != null
                    ? Chewie(controller: _chewieController!)
                    : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.video.thumbnailUrl,
                          fit: BoxFit.cover,
                        ),
                        Center(
                          child: IconButton.filled(
                            onPressed: _initializePlayer,
                            icon: const Icon(Icons.play_arrow, size: 32),
                          ),
                        ),
                      ],
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.video.titleFor(locale),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.video.descriptionFor(locale),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
