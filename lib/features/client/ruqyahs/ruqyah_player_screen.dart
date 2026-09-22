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

  Future<void> _seekBy(int seconds) async {
    final target = _position + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > _duration ? _duration : target);
    await _audioPlayer.seek(clamped);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.navy),
        title: Text(
          'تشغيل الرقية',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, fontSize: 16),
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
                  borderRadius: BorderRadius.circular(22),
                  child: YoutubePlayer(controller: _youtubeController!),
                ),
                const SizedBox(height: 22),
                Text(
                  widget.ruqyah.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20),
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.navy],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 36,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.headphones_rounded,
                          color: Colors.white, size: 56),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  widget.ruqyah.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),

                const Spacer(),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        ),
                        child: Slider(
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.navy.withValues(alpha: 0.08),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(_position),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy.withValues(alpha: 0.5))),
                            Text(_formatDuration(_duration),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navy.withValues(alpha: 0.5))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.replay_10_rounded, color: AppColors.navy.withValues(alpha: 0.6), size: 28),
                            onPressed: () => _seekBy(-10),
                          ),
                          const SizedBox(width: 18),
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.primary, AppColors.navy],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 34,
                              ),
                              onPressed: _togglePlayPause,
                            ),
                          ),
                          const SizedBox(width: 18),
                          IconButton(
                            icon: Icon(Icons.forward_10_rounded, color: AppColors.navy.withValues(alpha: 0.6), size: 28),
                            onPressed: () => _seekBy(10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
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