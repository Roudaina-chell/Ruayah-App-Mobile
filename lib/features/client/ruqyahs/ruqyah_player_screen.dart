import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/ruqyah.dart';

class RuqyahPlayerScreen extends StatefulWidget {
  final Ruqyah ruqyah;

  const RuqyahPlayerScreen({super.key, required this.ruqyah});

  @override
  State<RuqyahPlayerScreen> createState() => _RuqyahPlayerScreenState();
}

class _RuqyahPlayerScreenState extends State<RuqyahPlayerScreen> {
  YoutubePlayerController? _youtubeController;
   final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool get _isYoutube => widget.ruqyah.type == 'youtube';

  @override
  void initState() {
    super.initState();

    if (_isYoutube) {
      final videoId =
          YoutubePlayer.convertUrlToId(widget.ruqyah.youtubeUrl ?? '') ?? '';
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false),
      );
    } else {
      _audioPlayer.onDurationChanged.listen((d) {
        if (mounted) setState(() => _duration = d);
      });
      _audioPlayer.onPositionChanged.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state == ap.PlayerState.playing);
        }
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_position == Duration.zero) {
        await _audioPlayer.play(ap.UrlSource(widget.ruqyah.audioUrl!));
      } else {
        await _audioPlayer.resume();
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.navy),
        title: Text(
          'تشغيل الرقية',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (_isYoutube) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: YoutubePlayer(controller: _youtubeController!),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.ruqyah.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 30),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.veryLightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.headphones, color: AppColors.primary, size: 60),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.ruqyah.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 30),

                Slider(
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.navy.withValues(alpha: 0.1),
                  min: 0,
                  max: _duration.inSeconds.toDouble() > 0
                      ? _duration.inSeconds.toDouble()
                      : 1,
                  value: _position.inSeconds
                      .toDouble()
                      .clamp(0, _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1),
                  onChanged: (value) async {
                    await _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position),
                          style: TextStyle(fontSize: 12, color: AppColors.navy.withValues(alpha: 0.5))),
                      Text(_formatDuration(_duration),
                          style: TextStyle(fontSize: 12, color: AppColors.navy.withValues(alpha: 0.5))),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 34,
                    ),
                    onPressed: _togglePlayPause,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}