import 'package:flutter/material.dart';
import 'animated_brand_logo.dart';

/// A semi-transparent overlay that covers the screen while loading.
/// Shows the AnimatedBrandLogo pulsing in the centre.
class LuxuryLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LuxuryLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isLoading ? 1.0 : 0.0,
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
              child: const Center(
                child: AnimatedBrandLogo(size: 120),
              ),
            ),
          ),
      ],
    );
  }
}
