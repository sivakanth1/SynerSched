import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD3D4F4), // Soft Lilac
                Color(0xFFB7D0EC), // Light Blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Overlapping soft blobs (abstract curves)
        Positioned(
          top: -60,
          left: -40,
          child: _buildBlob(180, const Color(0x80FFFFFF)),
        ),
        Positioned(
          top: 150,
          right: -50,
          child: _buildBlob(240, const Color(0x60FFFFFF)),
        ),
        Positioned(
          bottom: -40,
          left: 40,
          child: _buildBlob(200, const Color(0x50FFFFFF)),
        ),
        Positioned(
          bottom: 100,
          right: 20,
          child: _buildBlob(150, const Color(0x30FFFFFF)),
        ),

        // Your screen content
        child,
      ],
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
