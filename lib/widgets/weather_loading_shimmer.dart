import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'glass_panel.dart';

class WeatherLoadingShimmer extends StatelessWidget {
  const WeatherLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.16),
      highlightColor: Colors.white.withValues(alpha: 0.28),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        children: const [
          _ShimmerLine(width: double.infinity, height: 52, radius: 14),
          SizedBox(height: 28),
          _ShimmerLine(width: 180, height: 28, radius: 14),
          SizedBox(height: 10),
          _ShimmerLine(width: 110, height: 14, radius: 8),
          SizedBox(height: 26),
          _ShimmerCircle(size: 88),
          SizedBox(height: 18),
          _ShimmerLine(width: 140, height: 84, radius: 20),
          SizedBox(height: 10),
          _ShimmerLine(width: 170, height: 22, radius: 12),
          SizedBox(height: 28),
          _ShimmerStatsRow(),
          SizedBox(height: 14),
          _ShimmerStatsRow(),
          SizedBox(height: 26),
          _ShimmerPanel(height: 170),
          SizedBox(height: 24),
          _ShimmerPanel(height: 250),
        ],
      ),
    );
  }
}

class _ShimmerStatsRow extends StatelessWidget {
  const _ShimmerStatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _ShimmerPanel(height: 92)),
        SizedBox(width: 12),
        Expanded(child: _ShimmerPanel(height: 92)),
        SizedBox(width: 12),
        Expanded(child: _ShimmerPanel(height: 92)),
      ],
    );
  }
}

class _ShimmerPanel extends StatelessWidget {
  final double height;

  const _ShimmerPanel({required this.height});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: height,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerLine(width: 120, height: 14, radius: 8),
            SizedBox(height: 16),
            Expanded(child: _ShimmerLine(width: double.infinity, height: double.infinity, radius: 16)),
          ],
        ),
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  final double size;

  const _ShimmerCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerLine({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
