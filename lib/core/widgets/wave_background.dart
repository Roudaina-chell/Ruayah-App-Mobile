import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WaveBackground extends StatelessWidget {
  const WaveBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Stack(
        children: [
          ClipPath(
            clipper: _WaveClipper(offset: 20),
            child: Container(
              color: AppColors.lightBlue.withValues(alpha: 0.35),
            ),
          ),
          ClipPath(
            clipper: _WaveClipper(offset: 0),
            child: Container(
              color: AppColors.lightBlue.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double offset;
  _WaveClipper({required this.offset});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.5 + offset);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.3 + offset,
      size.width * 0.5,
      size.height * 0.5 + offset,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7 + offset,
      size.width,
      size.height * 0.5 + offset,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}