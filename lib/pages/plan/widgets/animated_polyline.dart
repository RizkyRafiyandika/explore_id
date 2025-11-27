import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Widget that animates polyline drawing from start to end
class AnimatedPolylineLayer extends StatefulWidget {
  final List<LatLng> points;
  final Color color;
  final double strokeWidth;
  final Duration duration;
  final VoidCallback? onAnimationComplete;

  const AnimatedPolylineLayer({
    Key? key,
    required this.points,
    this.color = Colors.blue,
    this.strokeWidth = 5.0,
    this.duration = const Duration(milliseconds: 1500),
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<AnimatedPolylineLayer> createState() => _AnimatedPolylineLayerState();
}

class _AnimatedPolylineLayerState extends State<AnimatedPolylineLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedPolylineLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Determine whether to animate:
    // - animate when new points were added (length increased)
    // - animate when previously empty and now have points
    // otherwise, skip animation and complete the controller
    final oldCount = oldWidget.points.length;
    final newCount = widget.points.length;

    final shouldAnimate =
        (oldCount == 0 && newCount > 0) || (newCount > oldCount);

    if (shouldAnimate) {
      _controller.reset();
      _controller.forward();
    } else {
      // No significant change, complete animation immediately
      _controller.value = 1.0;
    }

    // No need to store last count because we compare oldWidget.points to widget.points
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Calculate partial points based on animation progress
  List<LatLng> _getAnimatedPoints(double progress) {
    if (widget.points.isEmpty) return [];
    if (progress >= 1.0) return widget.points;

    final totalPoints = widget.points.length;
    final visibleCount = (totalPoints * progress).ceil();

    if (visibleCount <= 0) return [];
    if (visibleCount >= totalPoints) return widget.points;

    return widget.points.sublist(0, visibleCount);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedPoints = _getAnimatedPoints(_animation.value);

        if (animatedPoints.isEmpty) {
          return const SizedBox.shrink();
        }

        return PolylineLayer(
          polylines: [
            Polyline(
              points: animatedPoints,
              strokeWidth: widget.strokeWidth,
              color: widget.color,
              borderStrokeWidth: 1.0,
              borderColor: widget.color.withOpacity(0.4),
            ),
          ],
        );
      },
    );
  }
}

/// Controller for managing animated polyline state from parent
class AnimatedPolylineController extends ChangeNotifier {
  List<LatLng> _points = [];
  bool _isAnimating = false;
  int _animationKey = 0;

  List<LatLng> get points => _points;
  bool get isAnimating => _isAnimating;
  int get animationKey => _animationKey;

  /// Update polyline points and trigger animation
  void updateRoute(List<LatLng> newPoints) {
    _points = newPoints;
    _isAnimating = true;
    _animationKey++;
    notifyListeners();
  }

  /// Clear the polyline
  void clear() {
    _points = [];
    _isAnimating = false;
    notifyListeners();
  }

  /// Called when animation completes
  void onAnimationComplete() {
    _isAnimating = false;
    notifyListeners();
  }
}
