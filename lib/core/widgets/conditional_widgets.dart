import 'package:flutter/widgets.dart';
import '../config/app_config.dart';

/// A widget that conditionally renders its child based on the climate feature flag.
///
/// When [AppConfig.includeClimate] is false, this widget renders as [SizedBox.shrink].
/// When true, it renders the provided [child].
class ClimateFeature extends StatelessWidget {
  final Widget child;

  const ClimateFeature({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.includeClimate) {
      return const SizedBox.shrink();
    }
    return child;
  }
}

/// A widget that conditionally renders one of two widgets based on the climate feature flag.
///
/// When [AppConfig.includeClimate] is true, renders [climateChild].
/// When false, renders [nonClimateChild] (or [SizedBox.shrink] if not provided).
class ClimateConditional extends StatelessWidget {
  final Widget climateChild;
  final Widget nonClimateChild;

  const ClimateConditional({
    super.key,
    required this.climateChild,
    this.nonClimateChild = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    if (AppConfig.includeClimate) {
      return climateChild;
    }
    return nonClimateChild;
  }
}
