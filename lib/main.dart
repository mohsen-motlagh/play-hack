import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:play_hack/player_page.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  runApp(const MyApp());

  JustAudioBackground.init(
    androidNotificationChannelId: 'com.playHack.myapp.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final YoutubeExplode yt = YoutubeExplode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Play Hack'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Animate(effects: const [
              FadeEffect(duration: Duration(seconds: 2)),
              ScaleEffect(duration: Duration(seconds: 2))
            ], onPlay: (controller) => controller.repeat(), child: const Text('WELCOME TO PLAY HACK')),
            const SizedBox(height: 50),
            const Text(
              'Please enter the url of the youtube video you want to play',
              textAlign: TextAlign.center,
            ).animate().tint(color: Colors.purple),
            const SizedBox(height: 50),
            TextField(
              decoration: const InputDecoration(
                hintText: 'write the url',
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              controller: _controller,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 50),
                ),
              ),
              onPressed: () async {
                final stream = await yt.videos.streams.getManifest(_controller.text);
                final manifest = await yt.videos.get(_controller.text);
                final video = stream.videoOnly.first;
                final audio = stream.audioOnly.first;
                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return PlayerPage(videoUrl: video.url, audioUrl: audio.url, stream: manifest);
                      },
                    ),
                  );
                }
              },
              child: const Text('Play'),
            ),
          ],
        ),
      ),
    );
  }
}
