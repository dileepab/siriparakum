import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class BalancePieChart extends StatelessWidget {
  final num totalExpenses;
  final num totalDonations;
  final num totalSubscriptions;

  const BalancePieChart({
    required this.totalExpenses,
    required this.totalDonations,
    required this.totalSubscriptions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {
      'Expenses': totalExpenses.toDouble(),
      'Donations': totalDonations.toDouble(),
      'Subscriptions': totalSubscriptions.toDouble(),
    };

    return Expanded(
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 2000),
        chartLegendSpacing: 32,
        chartRadius: double.infinity,
        ringStrokeWidth: 32,
        centerText: '',
        legendOptions: const LegendOptions(
          showLegends: true,
          legendPosition: LegendPosition.bottom,
          showLegendsInRow: true,
          legendTextStyle: TextStyle(fontSize: 12),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValuesInPercentage: false,
          showChartValues: true,
          showChartValuesOutside: false,
        ),
      ),
    );
  }
}
