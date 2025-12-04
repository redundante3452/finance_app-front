import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/features/transactions/models/transaction_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartsWidget extends StatelessWidget {
  final List<TransactionModel> transactions;

  const ChartsWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in transactions) {
      if (t.type == 'INCOME') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    return Column(
      children: [
        // Bar Chart (Income vs Expense)
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: AppColors.surface.withOpacity(0.8),
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppColors.primary.withOpacity(0.4),
                width: 1,
              ),
            ),
            shadows: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BALANCE GENERAL',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 2.0,
                      color: AppColors.accent,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: AppColors.surfaceLight,
                        tooltipRoundedRadius: 4,
                        tooltipPadding: const EdgeInsets.all(8),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toStringAsFixed(0)}',
                            const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
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
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                value == 0 ? 'INGRESOS' : 'GASTOS',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1000,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppColors.surfaceLight.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: totalIncome,
                            color: AppColors.success,
                            width: 30,
                            borderRadius: BorderRadius.circular(2),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.2,
                              color: AppColors.surfaceLight.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: totalExpense,
                            color: AppColors.error,
                            width: 30,
                            borderRadius: BorderRadius.circular(2),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.2,
                              color: AppColors.surfaceLight.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
