# Hourly Chart Scroll Fix - Implementation Plan

## Problem Analysis

### Current Issue
The hourly chart scrolls to the wrong position when trying to show "now - 1h" at the left edge of the viewport.

### Root Cause
**Mismatch between scroll calculation and chart rendering:**

1. **Scroll Calculation** (in `weather_chart_widget.dart:180`):
   - Uses index-based positioning: `targetOffset = index * itemWidth`
   - Assumes each hour takes exactly 60 pixels (`hourlyChartWidthPerHour`)
   - This is a **linear, evenly-spaced** approach

2. **Chart Rendering** (in `hourly_chart_builder.dart:31-35`):
   - Uses time-based positioning with milliseconds
   - X-axis range: `minX` to `maxX` (in milliseconds since epoch)
   - Position is calculated as: `(time - minX) / (maxX - minX) * chartWidth`
   - This is a **proportional, time-based** approach

### Why This Causes Problems
- The scroll assumes uniform spacing (60px per hour)
- But the chart positions data points based on their actual time within the total time range
- If the chart width doesn't match `hourCount * 60`, positions will be misaligned

## Solution Design

### Approach
Calculate the scroll offset using the **same time-based logic** as the chart rendering.

### Formula
```dart
// 1. Get the target time (now - 1h) in milliseconds
targetTime = (DateTime.now() - 1h).millisecondsSinceEpoch

// 2. Get the chart's time range (from hourly_chart_builder.dart)
startTime = hourlyWeather.hourlyForecasts.first.time
minX = startTime.millisecondsSinceEpoch
maxX = startTime.add(Duration(hours: 44)).millisecondsSinceEpoch

// 3. Calculate the chart's drawable width
chartWidth = totalWidth - leftPadding - rightPadding - leftTitleReservedSize

// 4. Calculate the proportion of time elapsed
timeProportion = (targetTime - minX) / (maxX - minX)

// 5. Calculate the pixel position within the chart
chartPixelPosition = timeProportion * chartWidth

// 6. Calculate the scroll offset (accounting for left padding)
scrollOffset = chartPixelPosition + leftPadding + leftTitleReservedSize
```

### Key Constants (from `chart_constants.dart`)
- `leftPadding = 10`
- `leftTitleReservedSize = 40`
- `rightPadding = 10`
- `hourlyChartWidthPerHour = 60`

## Implementation Steps

### 1. Modify `_scrollToCurrentTime()` method
- Change to pass the actual DateTime instead of just the index
- Calculate the target time (now - 1h)

### 2. Modify `_scrollToHourlyIndexLeftAligned()` method
**Rename to:** `_scrollToHourlyTime(DateTime targetTime)`

**New implementation using ChartHelpers.calculateScreenPosition2():**
```dart
void _scrollToHourlyTime(DateTime targetTime) {
  if (!_scrollController.hasClients || widget.hourlyWeather == null) return;
  
  final hourlyWeather = widget.hourlyWeather!;
  
  // Calculate chart dimensions (must match the actual chart size)
  final totalWidth = hourlyWeather.hourlyForecasts.length * ChartConstants.hourlyChartWidthPerHour;
  final containerSize = Size(totalWidth, ChartConstants.hourlyChartHeight);
  
  // Use the same method that positions elements in the chart
  // This ensures consistency with how the chart renders
  final screenPos = ChartHelpers.calculateScreenPosition2(
    targetTime.millisecondsSinceEpoch.toDouble(),
    _minTemp, // Y coordinate doesn't matter for X position
    containerSize,
    _minTemp,
    _maxTemp,
    hourlyWeather,
  );
  
  // The X position from calculateScreenPosition2 already includes padding
  // So we can use it directly as the scroll offset
  double targetOffset = screenPos.dx;
  
  // Clamp to valid scrollable range
  final maxExtent = _scrollController.position.maxScrollExtent;
  targetOffset = targetOffset.clamp(0.0, maxExtent);
  
  // Animate to position
  _scrollController.animateTo(
    targetOffset,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
}
```

**Why use ChartHelpers.calculateScreenPosition2()?**
- It's the same method used throughout the codebase for positioning chart elements
- Ensures consistency with how the chart calculates positions
- Already handles all the padding, time range, and coordinate transformations correctly
- Proven to work reliably in other parts of the code

### 3. Update `_scrollToCurrentTime()` to use new method
```dart
void _scrollToCurrentTime() {
  final hourlyWeather = widget.hourlyWeather;
  if (hourlyWeather == null || !_scrollController.hasClients) return;
  
  final DateTime targetTime = DateTime.now().subtract(const Duration(hours: 1));
  _scrollToHourlyTime(targetTime);
}
```

## Testing Checklist

- [ ] Chart scrolls to correct position on initial load
- [ ] "Now - 1h" appears at the left edge of the viewport
- [ ] Scroll position is correct regardless of total chart width
- [ ] Edge cases handled:
  - [ ] Target time before chart start (scrolls to beginning)
  - [ ] Target time after chart end (scrolls to end)
  - [ ] Chart with different hour counts
- [ ] Scroll animation is smooth
- [ ] No console errors

## Debug Logging (Optional)

Add these print statements to verify calculations:
```dart
print('Target time: $targetTime');
print('Chart time range: $minX to $maxX');
print('Time proportion: $timeProportion');
print('Chart width: $chartWidth');
print('Calculated scroll offset: $targetOffset');
print('Max scroll extent: $maxExtent');
```

## Files to Modify

1. **`lib/widgets/weather_chart_widget.dart`**
   - Method: `_scrollToCurrentTime()` (lines 147-174)
   - Method: `_scrollToHourlyIndexLeftAligned()` (lines 176-194)

## Expected Outcome

After implementation:
- The hourly chart will scroll to show "now - 1h" at the left edge of the viewport
- The scroll position will be accurate regardless of chart width or time range
- The calculation will match the chart's time-based rendering logic