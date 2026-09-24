import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shimmering skeleton block for loading states (products, orders, etc).
class SkeletonBox extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const SkeletonBox({super.key, this.height = 16, this.width, this.borderRadius = 10});

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + t * 2, 0),
              end: Alignment(0 + t * 2, 0),
              colors: [
                VorexColors.bgPanel,
                VorexColors.bgPanel.withOpacity(0.4),
                VorexColors.bgPanel,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBox(height: 120, borderRadius: 16),
          SizedBox(height: 8),
          SkeletonBox(height: 12, width: 100),
          SizedBox(height: 6),
          SkeletonBox(height: 12, width: 60),
        ],
      ),
    );
  }
}
