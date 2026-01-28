/// Configuration for chart dimensions and spacing to ensure
/// external widgets (Positioned) align perfectly with fl_chart axes.
class ChartConfig {
  final double leftReservedSize;
  final double rightReservedSize;
  final double topReservedSize;
  final double bottomReservedSize;
  final double borderWidth;

  // Axis name sizes (the space for axis titles like "°C" or "Température")
  final double leftAxisNameSize;
  final double bottomAxisNameSize;

  const ChartConfig({
    this.leftReservedSize = 30.0,
    this.rightReservedSize = 0.0,
    this.topReservedSize = 0.0,
    this.bottomReservedSize = 30.0,
    this.borderWidth = 1.0,
    this.leftAxisNameSize = 20.0,
    this.bottomAxisNameSize = 20.0,
  });

  /// Default configuration matching ChartConstants for temperature charts
  factory ChartConfig.temperature() {
    return const ChartConfig(
      leftReservedSize: 30.0,
      rightReservedSize: 0.0,
      topReservedSize: 0.0,
      bottomReservedSize: 30.0,
      borderWidth: 1.0,
      leftAxisNameSize: 20.0,
      bottomAxisNameSize: 20.0,
    );
  }

  /// Configuration for wind charts
  factory ChartConfig.wind() {
    return const ChartConfig(
      leftReservedSize: 30.0,
      rightReservedSize: 0.0,
      topReservedSize: 0.0,
      bottomReservedSize: 30.0,
      borderWidth: 1.0,
      leftAxisNameSize: 20.0,
      bottomAxisNameSize: 20.0,
    );
  }

  /// Total horizontal space taken by decorations (axes/borders)
  double get horizontalReserved =>
      leftReservedSize +
      rightReservedSize +
      leftAxisNameSize +
      (2 * borderWidth);

  /// Total vertical space taken by decorations (axes/borders)
  double get verticalReserved =>
      topReservedSize +
      bottomReservedSize +
      bottomAxisNameSize +
      (2 * borderWidth);

  /// Gets the left offset where the chart drawing area starts
  double get chartAreaLeft => leftReservedSize + leftAxisNameSize + borderWidth;

  /// Gets the top offset where the chart drawing area starts
  double get chartAreaTop => topReservedSize + borderWidth;
}
