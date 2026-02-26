import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Animated brand logo widget using the real Zyiarah SVG logo.
/// Produces a luxury pulsing effect via ScaleTransition + FadeTransition.
class AnimatedBrandLogo extends StatefulWidget {
  final double size;
  const AnimatedBrandLogo({super.key, this.size = 120});

  @override
  State<AnimatedBrandLogo> createState() => _AnimatedBrandLogoState();
}

class _AnimatedBrandLogoState extends State<AnimatedBrandLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacity = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: SvgPicture.asset(
          'assets/images/logo.svg',
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => SizedBox(
            width: widget.size,
            height: widget.size,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}
