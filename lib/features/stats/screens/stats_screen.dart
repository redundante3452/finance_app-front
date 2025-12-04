import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/core/widgets/tech_text.dart';
import 'package:finance_app/core/widgets/eva_icon.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finance_app/core/providers/global_providers.dart';
import 'package:finance_app/features/categories/models/category_model.dart';
import 'package:finance_app/features/stats/screens/category_transactions_screen.dart';
import 'package:finance_app/features/transactions/models/transaction_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const TechText(
          'ESTADÍSTICAS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          return categoriesAsync.when(
            data: (categories) {
              if (transactions.isEmpty) {
                return const Center(child: Text('No hay datos suficientes'));
              }
              return _StatsContent(
                transactions: transactions,
                categories: categories,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error categorías: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error transacciones: $err')),
      ),
    );
  }
}

class _StatsContent extends StatefulWidget {
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;

  const _StatsContent({
    required this.transactions,
    required this.categories,
  });

  @override
  State<_StatsContent> createState() => _StatsContentState();
}

class _StatsContentState extends State<_StatsContent> {
  DateTime _selectedDate = DateTime.now();
  int? _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Filter transactions by month and year
    final filteredTransactions = widget.transactions.where((t) {
      final date = t.date;
      return date.year == _selectedDate.year && date.month == _selectedDate.month;
    }).toList();

    // Calculate expenses by category
    final Map<String, double> categoryExpenses = {};
    double totalExpense = 0;

    for (var t in filteredTransactions) {
      if (t.type == 'EXPENSE') {
        final categoryId = t.categoryId;
        // Find category name
        final categoryName = widget.categories
            .firstWhere(
              (c) => c.id == categoryId,
              orElse: () => CategoryModel(id: 'unknown', name: 'Otros', type: 'EXPENSE'),
            )
            .name;
            
        categoryExpenses[categoryName] = (categoryExpenses[categoryName] ?? 0) + t.amount;
        totalExpense += t.amount;
      }
    }

    final sortedEntries = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        children: [
          // Date Picker
          Center(
            child: _MonthSelector(
              selectedDate: _selectedDate,
              onChanged: (date) => setState(() => _selectedDate = date),
            ),
          ),
          const SizedBox(height: 32),

          if (totalExpense == 0)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  EvaIcon(
                    Icons.pie_chart_outline_rounded,
                    size: 80,
                    color: AppColors.textDim.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay gastos en este mes',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textDim,
                        ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms).scale(),
            )
          else ...[
             const Text(
              'Gastos por Categoría',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            // Pie Chart
            SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                   PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sections: List.generate(sortedEntries.length, (i) {
                        final entry = sortedEntries[i];
                        final isTouched = i == _touchedIndex;
                        final fontSize = isTouched ? 20.0 : 14.0;
                        final radius = isTouched ? 70.0 : 60.0;
                        final percentage = (entry.value / totalExpense) * 100;
                        final color = Colors.primaries[entry.key.hashCode % Colors.primaries.length];

                        return PieChartSectionData(
                          color: color,
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(0)}%',
                          radius: radius,
                          titleStyle: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
                          ),
                        );
                      }),
                      centerSpaceRadius: 70,
                      sectionsSpace: 2,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '\$${totalExpense.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // List of categories
            ...sortedEntries.map((entry) {
               final color = Colors.primaries[entry.key.hashCode % Colors.primaries.length];
               return GestureDetector(
                 onTap: () {
                   // Filter transactions for this category
                   final categoryTransactions = filteredTransactions.where((t) {
                      // We need to match by ID, but here we only have the name in the entry key.
                      // This is a small flaw in the previous logic.
                      // Let's find the category ID from the name or re-filter properly.
                      // Better approach: The entry key is the name. We need to find the category ID corresponding to this name 
                      // OR we can just filter by name if names are unique (which they should be for display).
                      // However, the map was built using names.
                      // Let's find the category object that matches this name.
                      final category = widget.categories.firstWhere(
                        (c) => c.name == entry.key,
                        orElse: () => CategoryModel(id: 'unknown', name: 'Otros', type: 'EXPENSE'),
                      );
                      return t.categoryId == category.id;
                   }).toList();

                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => CategoryTransactionsScreen(
                         categoryName: entry.key,
                         transactions: categoryTransactions,
                       ),
                     ),
                   );
                 },
                 child: Container(
                   margin: const EdgeInsets.only(bottom: 12),
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: AppColors.surface,
                     borderRadius: BorderRadius.circular(16),
                   ),
                   child: Row(
                     children: [
                       Container(
                         width: 12,
                         height: 12,
                         decoration: BoxDecoration(
                           color: color,
                           shape: BoxShape.circle,
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Text(
                           entry.key,
                           style: const TextStyle(
                             fontSize: 16,
                             fontWeight: FontWeight.w500,
                             color: AppColors.textPrimary,
                           ),
                         ),
                       ),
                       Text(
                         '-\$${entry.value.toStringAsFixed(2)}',
                         style: const TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.bold,
                           color: Colors.redAccent,
                           decoration: TextDecoration.none, // Ensure no underline from GestureDetector
                         ),
                       ),
                       const SizedBox(width: 8),
                       const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                     ],
                   ),
                 ),
               );
            }).toList(),

            const SizedBox(height: 48),
            const Text(
              'Gastos Diarios',
              style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            // Bar Chart
            _DailyExpensesBarChart(transactions: filteredTransactions, selectedDate: _selectedDate),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  const _MonthSelector({required this.selectedDate, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.primary),
            onPressed: () {
              onChanged(DateTime(selectedDate.year, selectedDate.month - 1));
            },
          ),
          Text(
            DateFormat('MMMM yyyy', 'es').format(selectedDate).toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.primary),
            onPressed: () {
              onChanged(DateTime(selectedDate.year, selectedDate.month + 1));
            },
          ),
        ],
      ),
    );
  }
}

class _DailyExpensesBarChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final DateTime selectedDate;

  const _DailyExpensesBarChart({
    required this.transactions,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate daily expenses
    final Map<int, double> dailyExpenses = {};
    final daysInMonth = DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month);

    for (var t in transactions) {
      if (t.type == 'EXPENSE') {
        final day = t.date.day;
        dailyExpenses[day] = (dailyExpenses[day] ?? 0) + t.amount;
      }
    }

    // Find max expense for Y-axis scaling
    double maxExpense = 0;
    if (dailyExpenses.isNotEmpty) {
      maxExpense = dailyExpenses.values.reduce((a, b) => a > b ? a : b);
    }
    // Add some buffer
    maxExpense = maxExpense == 0 ? 100 : maxExpense * 1.2;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxExpense,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.surface,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '\$${rod.toY.toStringAsFixed(2)}',
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
                  final day = value.toInt();
                  if (day % 5 == 0 || day == 1 || day == daysInMonth) {
                     return Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text(
                         day.toString(),
                         style: const TextStyle(
                           color: AppColors.textSecondary,
                           fontSize: 10,
                         ),
                       ),
                     );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(daysInMonth, (index) {
            final day = index + 1;
            final amount = dailyExpenses[day] ?? 0;
            return BarChartGroupData(
              x: day,
              barRods: [
                BarChartRodData(
                  toY: amount,
                  color: AppColors.primary,
                  width: 6,
                  borderRadius: BorderRadius.circular(2),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxExpense,
                    color: AppColors.surface,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
