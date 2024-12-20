import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlayerPage extends StatefulWidget {
  final Uri videoUrl;
  final Uri audioUrl;
  final Video stream;
  const PlayerPage({super.key, required this.audioUrl, required this.videoUrl, required this.stream});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    audioPlayer = AudioPlayer();
    initAudioPlayer();
    // initVideoPlayer();
    audioPlayer.playerStateStream.listen((playerState) {});
    super.initState();
  }

  void initAudioPlayer() async {
    await audioPlayer.setAudioSource(
      AudioSource.uri(
        widget.audioUrl,
        tag: MediaItem(
          id: widget.stream.id.toString(),
          title: widget.stream.title,
          artist: widget.stream.author,
          duration: Duration(seconds: widget.stream.duration!.inSeconds),
          artUri: Uri.parse(widget.stream.thumbnails.mediumResUrl),
        ),
      ),
    );

    audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        setState(() {
          isPlaying = true;
        });
      } else {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  // void initVideoPlayer() async {
  //   _controller = VideoPlayerController.networkUrl(
  //     widget.videoUrl,
  //   );
  //   await _controller.initialize();
  //   chewieController = ChewieController(
  //     videoPlayerController: _controller,
  //     autoPlay: false,
  //     looping: true,
  //   );
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(widget.stream.thumbnails.highResUrl),
            const SizedBox(height: 30),
            Text(widget.stream.title)
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .tint(color: Colors.purple)
                .saturate(duration: const Duration(seconds: 3)),
            const SizedBox(height: 30),
            StreamBuilder<Duration>(
                stream: audioPlayer.positionStream,
                builder: (context, duration) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: ProgressBar(
                        onSeek: (seek) {
                          audioPlayer.seek(seek);
                        },
                        progress: duration.data ?? Duration.zero,
                        total: widget.stream.duration ?? Duration.zero),
                  );
                }),
            StreamBuilder<PlayerState>(
                stream: audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  isPlaying = playerState?.playing ?? false;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await audioPlayer.seek(Duration(seconds: audioPlayer.position.inSeconds - 10));
                        },
                        icon: const Icon(Icons.replay_10),
                      ),
                      IconButton(
                        onPressed: () async {
                          isPlaying ? await audioPlayer.pause() : await audioPlayer.play();
                        },
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      ),
                      IconButton(
                        onPressed: () async {
                          await audioPlayer.seek(Duration(seconds: audioPlayer.position.inSeconds + 10));
                        },
                        icon: const Icon(Icons.forward_10),
                      ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    //_controller.dispose();
    // audioPlayer.stop();
    audioPlayer.dispose();
    super.dispose();
  }
}
