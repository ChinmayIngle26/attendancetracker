import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum ChartType { bar, line, pie }

class AttendanceChart extends StatefulWidget {
  final List<Map<String, dynamic>> chartData;
  final ChartType chartType;
  final String title;
  final Function(ChartType)? onChartTypeChanged;

  const AttendanceChart({
    super.key,
    required this.chartData,
    required this.chartType,
    required this.title,
    this.onChartTypeChanged,
  });

  @override
  State<AttendanceChart> createState() => _AttendanceChartState();
}

class _AttendanceChartState extends State<AttendanceChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(widget.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600))),
            if (widget.onChartTypeChanged != null)
              PopupMenuButton<ChartType>(
                  icon: CustomIconWidget(
                      iconName: 'more_vert',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20),
                  onSelected: widget.onChartTypeChanged,
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            value: ChartType.bar,
                            child: Row(children: [
                              CustomIconWidget(
                                  iconName: 'bar_chart',
                                  color: theme.colorScheme.onSurface,
                                  size: 20),
                              SizedBox(width: 2.w),
                              const Text('Bar Chart'),
                            ])),
                        PopupMenuItem(
                            value: ChartType.line,
                            child: Row(children: [
                              CustomIconWidget(
                                  iconName: 'show_chart',
                                  color: theme.colorScheme.onSurface,
                                  size: 20),
                              SizedBox(width: 2.w),
                              const Text('Line Chart'),
                            ])),
                        PopupMenuItem(
                            value: ChartType.pie,
                            child: Row(children: [
                              CustomIconWidget(
                                  iconName: 'pie_chart',
                                  color: theme.colorScheme.onSurface,
                                  size: 20),
                              SizedBox(width: 2.w),
                              const Text('Pie Chart'),
                            ])),
                      ]),
          ]),
          SizedBox(height: 3.h),
          SizedBox(height: 30.h, child: _buildChart(context, theme)),
          if (widget.chartType == ChartType.pie) ...[
            SizedBox(height: 2.h),
            _buildPieChartLegend(context, theme),
          ],
        ]));
  }

  Widget _buildChart(BuildContext context, ThemeData theme) {
    switch (widget.chartType) {
      case ChartType.bar:
        return _buildBarChart(theme);
      case ChartType.line:
        return _buildLineChart(theme);
      case ChartType.pie:
        return _buildPieChart(theme);
    }
  }

  Widget _buildBarChart(ThemeData theme) {
    if (widget.chartData.isEmpty) {
      return _buildEmptyChart(theme, 'No data available for bar chart');
    }

    return BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final data = widget.chartData[groupIndex];
                  final subjectName = data['name'] as String? ?? 'Unknown';
                  final percentage = rod.toY;
                  return BarTooltipItem(
                      '$subjectName\n${percentage.toStringAsFixed(1)}%',
                      TextStyle(
                          color: theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.w500));
                })),
        titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < widget.chartData.length) {
                        final subjectName =
                            widget.chartData[index]['name'] as String? ?? '';
                        return Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Text(
                                subjectName.length > 8
                                    ? '${subjectName.substring(0, 8)}...'
                                    : subjectName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6))));
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 4.h)),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6)));
                    },
                    reservedSize: 10.w))),
        borderData: FlBorderData(show: false),
        barGroups: widget.chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final totalLectures = data['totalLectures'] as int? ?? 0;
          final attendedLectures = data['attendedLectures'] as int? ?? 0;
          final percentage = totalLectures > 0
              ? (attendedLectures / totalLectures) * 100
              : 0.0;
          final color = Color(data['color'] as int? ?? 0xFF2E7D32);

          return BarChartGroupData(x: index, barRods: [
            BarChartRodData(
                toY: percentage,
                color: percentage >= 75 ? color : theme.colorScheme.error,
                width: 6.w,
                borderRadius: BorderRadius.circular(2),
                backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3))),
          ]);
        }).toList(),
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  strokeWidth: 1);
            })));
  }

  Widget _buildLineChart(ThemeData theme) {
    if (widget.chartData.isEmpty) {
      return _buildEmptyChart(theme, 'No data available for line chart');
    }

    return LineChart(LineChartData(
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  strokeWidth: 1);
            }),
        titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 4.h,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < widget.chartData.length) {
                        final subjectName =
                            widget.chartData[index]['name'] as String? ?? '';
                        return Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Text(
                                subjectName.length > 6
                                    ? '${subjectName.substring(0, 6)}...'
                                    : subjectName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6))));
                      }
                      return const SizedBox.shrink();
                    })),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    interval: 25,
                    reservedSize: 10.w,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6)));
                    }))),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (widget.chartData.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
              spots: widget.chartData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final totalLectures = data['totalLectures'] as int? ?? 0;
                final attendedLectures = data['attendedLectures'] as int? ?? 0;
                final percentage = totalLectures > 0
                    ? (attendedLectures / totalLectures) * 100
                    : 0.0;
                return FlSpot(index.toDouble(), percentage);
              }).toList(),
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    final data = widget.chartData[index];
                    final totalLectures = data['totalLectures'] as int? ?? 0;
                    final attendedLectures =
                        data['attendedLectures'] as int? ?? 0;
                    final percentage = totalLectures > 0
                        ? (attendedLectures / totalLectures) * 100
                        : 0.0;
                    final color = percentage >= 75
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error;

                    return FlDotCirclePainter(
                        radius: 4,
                        color: color,
                        strokeWidth: 2,
                        strokeColor: theme.colorScheme.surface);
                  }),
              belowBarData: BarAreaData(
                  show: true,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1))),
          // Threshold line at 75%
          LineChartBarData(
              spots: [
                const FlSpot(0, 75),
                FlSpot((widget.chartData.length - 1).toDouble(), 75),
              ],
              isCurved: false,
              color: theme.colorScheme.error,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5]),
        ],
        lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: 8,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    if (touchedSpot.barIndex == 0) {
                      final index = touchedSpot.x.toInt();
                      if (index >= 0 && index < widget.chartData.length) {
                        final data = widget.chartData[index];
                        final subjectName =
                            data['name'] as String? ?? 'Unknown';
                        final percentage = touchedSpot.y;
                        return LineTooltipItem(
                            '$subjectName\n${percentage.toStringAsFixed(1)}%',
                            TextStyle(
                                color: theme.colorScheme.onInverseSurface,
                                fontWeight: FontWeight.w500));
                      }
                    }
                    return null;
                  }).toList();
                }))));
  }

  Widget _buildPieChart(ThemeData theme) {
    if (widget.chartData.isEmpty) {
      return _buildEmptyChart(theme, 'No data available for pie chart');
    }

    return PieChart(PieChartData(
        pieTouchData:
            PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                pieTouchResponse == null ||
                pieTouchResponse.touchedSection == null) {
              _touchedIndex = -1;
              return;
            }
            _touchedIndex =
                pieTouchResponse.touchedSection!.touchedSectionIndex;
          });
        }),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 15.w,
        sections: widget.chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final totalLectures = data['totalLectures'] as int? ?? 0;
          final attendedLectures = data['attendedLectures'] as int? ?? 0;
          final percentage = totalLectures > 0
              ? (attendedLectures / totalLectures) * 100
              : 0.0;
          final color = Color(data['color'] as int? ?? 0xFF2E7D32);
          final isTouched = index == _touchedIndex;
          final radius = isTouched ? 12.w : 10.w;

          return PieChartSectionData(
              color: color,
              value: percentage,
              title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
              radius: radius,
              titleStyle: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold));
        }).toList()));
  }

  Widget _buildPieChartLegend(BuildContext context, ThemeData theme) {
    return Wrap(
        spacing: 4.w,
        runSpacing: 1.h,
        children: widget.chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final subjectName = data['name'] as String? ?? 'Unknown';
          final totalLectures = data['totalLectures'] as int? ?? 0;
          final attendedLectures = data['attendedLectures'] as int? ?? 0;
          final percentage = totalLectures > 0
              ? (attendedLectures / totalLectures) * 100
              : 0.0;
          final color = Color(data['color'] as int? ?? 0xFF2E7D32);

          return Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 3.w,
                height: 3.w,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            SizedBox(width: 1.w),
            Text('$subjectName (${percentage.toStringAsFixed(1)}%)',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          ]);
        }).toList());
  }

  Widget _buildEmptyChart(ThemeData theme, String message) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomIconWidget(
          iconName: 'bar_chart',
          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          size: 48),
      SizedBox(height: 2.h),
      Text(message,
          style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          textAlign: TextAlign.center),
    ]));
  }
}
