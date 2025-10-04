import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/colors.dart';

/// Pie chart widget for category spending breakdown
class SpendingPieChart extends StatelessWidget {
  final List<PieChartData> data;
  final double size;
  final bool showLegend;

  const SpendingPieChart({
    Key? key,
    required this.data,
    this.size = 200,
    this.showLegend = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyChart('No data available');
    }

    return Column(
      children: [
        SizedBox(
          height: size,
          child: PieChart(
            PieChartData(
              sections: data.map((item) {
                return PieChartSectionData(
                  value: item.value,
                  title: '${item.percentage.toStringAsFixed(1)}%',
                  color: item.color,
                  radius: size * 0.4,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: size * 0.2,
            ),
          ),
        ),
        if (showLegend) ...[const SizedBox(height: 20), _buildLegend()],
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: data.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: size,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Bar chart widget for daily/monthly trends
class TrendBarChart extends StatelessWidget {
  final Map<int, double> data;
  final String title;
  final Color barColor;
  final double height;
  final String Function(int)? xAxisLabelBuilder;
  final String Function(double)? yAxisLabelBuilder;

  const TrendBarChart({
    Key? key,
    required this.data,
    required this.title,
    this.barColor = AppColors.expense,
    this.height = 200,
    this.xAxisLabelBuilder,
    this.yAxisLabelBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyChart('No data available');
    }

    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    final sortedKeys = data.keys.toList()..sort();

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.surface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final value = rod.toY;
                return BarTooltipItem(
                  yAxisLabelBuilder?.call(value) ??
                      '\$${value.toStringAsFixed(0)}',
                  TextStyle(color: AppColors.textPrimary),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (xAxisLabelBuilder != null) {
                    return Text(
                      xAxisLabelBuilder!(value.toInt()),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    );
                  }
                  if (value.toInt() % 5 == 0 || value.toInt() == 1) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    yAxisLabelBuilder?.call(value) ?? '\$${value.toInt()}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: AppColors.divider, strokeWidth: 1);
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: sortedKeys.map((key) {
            final value = data[key] ?? 0.0;
            return BarChartGroupData(
              x: key,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: barColor,
                  width: 6,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Line chart widget for balance trends
class LineChartWidget extends StatelessWidget {
  final List<LineChartPoint> data;
  final Color lineColor;
  final double height;
  final bool showDots;
  final String Function(double)? yAxisLabelBuilder;

  const LineChartWidget({
    Key? key,
    required this.data,
    this.lineColor = AppColors.primary,
    this.height = 200,
    this.showDots = true,
    this.yAxisLabelBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyChart('No data available');
    }

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minY = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppColors.surface,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final point = data[spot.x.toInt()];
                  return LineTooltipItem(
                    '${point.label}\n${yAxisLabelBuilder?.call(spot.y) ?? '\$${spot.y.toStringAsFixed(0)}'}',
                    TextStyle(color: AppColors.textPrimary),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: AppColors.divider, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    yAxisLabelBuilder?.call(value) ?? '\$${value.toInt()}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= data.length) {
                    return const SizedBox.shrink();
                  }
                  final point = data[value.toInt()];
                  return Text(
                    point.label,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: minY * 0.9,
          maxY: maxY * 1.1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: showDots),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Data classes for charts
class PieChartData {
  final String label;
  final double value;
  final double percentage;
  final Color color;

  PieChartData({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });
}

class LineChartPoint {
  final String label;
  final double value;

  LineChartPoint({required this.label, required this.value});
}
