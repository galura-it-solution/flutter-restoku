import 'package:flutter/material.dart';
import 'package:slims/core/constants/colors.dart';

class FoodBackground extends StatelessWidget {
  const FoodBackground({
    super.key,
    required this.child,
    this.imagePath = 'lib/assets/images/food_bg.jpg',
    this.overlayDark = 0.15,
    this.overlayLight = 0.9,
  });

  final Widget child;
  final String imagePath;
  final double overlayDark;
  final double overlayLight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: overlayDark),
                  MasterColor.white.withValues(alpha: overlayLight),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
