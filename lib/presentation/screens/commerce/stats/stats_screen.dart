import 'dart:math' as math;
import 'package:bombastik/domain/models/commerce_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bombastik/config/themes/app_theme.dart';
import 'package:bombastik/presentation/providers/commerce-providers/stats/stats_provider.dart';
import 'package:bombastik/presentation/widgets/gradient_sliver_app_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final now = DateTime.now();
        ref.read(selectedPeriodProvider.notifier).state = (
          startDate: DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(const Duration(days: 30)),
          endDate: now,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statsAsync = ref.watch(filteredStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            GradientSliverAppBar(
              title: 'Estadísticas',
              isDarkMode: isDark,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            isDark
                                ? [
                                  AppColors.statsGradientDarkStart.withOpacity(
                                    0.8,
                                  ),
                                  AppColors.statsGradientDarkEnd.withOpacity(
                                    0.9,
                                  ),
                                ]
                                : [
                                  AppColors.statsGradientStart.withOpacity(0.8),
                                  AppColors.statsGradientEnd.withOpacity(0.9),
                                ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  onPressed: _showPeriodSelector,
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),
                  statsAsync.when(
                    data:
                        (stats) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatsGrid(stats, theme, isDark),
                            const SizedBox(height: 24),
                            _buildTopProducts(stats.topProducts, theme, isDark),
                            const SizedBox(height: 24),
                            _buildSalesTrend(),
                          ],
                        ),
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stackTrace) => Center(
                          child: Text(
                            'Error al cargar las estadísticas',
                            style: GoogleFonts.poppins(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Consumer(
      builder: (context, ref, child) {
        final selectedPeriod = ref.watch(selectedPeriodProvider);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return PopupMenuButton<String>(
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: isDark ? Colors.grey[850] : Colors.white,
          elevation: 8,
          itemBuilder:
              (context) => [
                PopupMenuItem<String>(
                  value: '7d',
                  child: _buildPeriodOption(
                    'Últimos 7 días',
                    Icons.calendar_view_week_outlined,
                    theme,
                    isDark,
                  ),
                ),
                PopupMenuItem<String>(
                  value: '30d',
                  child: _buildPeriodOption(
                    'Últimos 30 días',
                    Icons.calendar_month_outlined,
                    theme,
                    isDark,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'custom',
                  child: _buildPeriodOption(
                    'Personalizado',
                    Icons.calendar_today_outlined,
                    theme,
                    isDark,
                  ),
                ),
              ],
          onSelected: (value) async {
            final now = DateTime.now();
            switch (value) {
              case '7d':
                ref.read(selectedPeriodProvider.notifier).state = (
                  startDate: now.subtract(const Duration(days: 7)),
                  endDate: now,
                );
                break;
              case '30d':
                ref.read(selectedPeriodProvider.notifier).state = (
                  startDate: now.subtract(const Duration(days: 30)),
                  endDate: now,
                );
                break;
              case 'custom':
                final dateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: DateTimeRange(
                    start: selectedPeriod.startDate,
                    end: selectedPeriod.endDate,
                  ),
                  builder: (context, child) {
                    return Theme(
                      data: theme.copyWith(
                        colorScheme: theme.colorScheme.copyWith(
                          primary: theme.colorScheme.primary,
                          onPrimary: theme.colorScheme.onPrimary,
                          surface: isDark ? Colors.grey[900]! : Colors.white,
                          onSurface: theme.colorScheme.onSurface,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (dateRange != null && mounted) {
                  ref.read(selectedPeriodProvider.notifier).state = (
                    startDate: dateRange.start,
                    endDate: dateRange.end,
                  );
                }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDark
                        ? [
                          AppColors.statsGradientDarkStart.withOpacity(0.8),
                          AppColors.statsGradientDarkEnd.withOpacity(0.9),
                        ]
                        : [
                          AppColors.statsGradientStart.withOpacity(0.8),
                          AppColors.statsGradientEnd.withOpacity(0.9),
                        ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(selectedPeriod.startDate)} - ${DateFormat('dd/MM/yyyy').format(selectedPeriod.endDate)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        ).animate().fadeIn().slideX(begin: 0.1);
      },
    );
  }

  Widget _buildPeriodOption(
    String text,
    IconData icon,
    ThemeData theme,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isDark
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(CommerceStats stats, ThemeData theme, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Ventas Totales',
          '\$${stats.totalSales.toStringAsFixed(2)}',
          Icons.attach_money_outlined,
          theme,
          isDark,
        ),
        _buildStatCard(
          'Pedidos',
          stats.totalOrders.toString(),
          Icons.shopping_bag_outlined,
          theme,
          isDark,
        ),
        _buildStatCard(
          'Clientes',
          stats.uniqueCustomers.toString(),
          Icons.people_outline,
          theme,
          isDark,
        ),
        _buildStatCard(
          'Productos\nVendidos',
          stats.topProducts
              .fold<int>(0, (sum, product) => sum + product.quantitySold)
              .toString(),
          Icons.inventory_2_outlined,
          theme,
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [
                    AppColors.statsGradientDarkStart,
                    AppColors.statsGradientDarkEnd,
                  ]
                  : [AppColors.statsGradientStart, AppColors.statsGradientEnd],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildTopProducts(
    List<ProductStats> products,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [
                    AppColors.statsGradientDarkStart.withOpacity(0.15),
                    AppColors.statsGradientDarkEnd.withOpacity(0.25),
                  ]
                  : [
                    AppColors.statsGradientStart.withOpacity(0.15),
                    AppColors.statsGradientEnd.withOpacity(0.25),
                  ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? AppColors.statsGradientDarkStart.withOpacity(0.3)
                          : AppColors.statsGradientStart.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color:
                      isDark
                          ? AppColors.statsGradientDarkStart
                          : AppColors.statsGradientStart,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Productos más vendidos',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No hay productos vendidos aún',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: products.length,
                itemBuilder:
                    (context, index) => _buildProductItem(
                      products[index],
                      theme,
                      isDark,
                      isLast: index == products.length - 1,
                    ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildSalesTrend() {
    return Consumer(
      builder: (context, ref, _) {
        final salesTrendAsync = ref.watch(salesTrendProvider(30));

        return salesTrendAsync.when(
          data: (salesData) {
            if (salesData.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No hay datos de ventas disponibles para mostrar',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final sortedEntries =
                salesData.entries.toList()
                  ..sort((a, b) => a.key.compareTo(b.key));

            final maxY = salesData.values.reduce(math.max) * 1.2;
            final minY = salesData.values.reduce(math.min) * 0.8;

            // Si maxY es 0, establecemos un valor mínimo
            final effectiveMaxY = maxY <= 0 ? 10.0 : maxY;
            final effectiveMinY = minY < 0 ? minY : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        Theme.of(context).colorScheme.primary.withOpacity(0.25),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.show_chart_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tendencia de ventas',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                              horizontalInterval: math.max(
                                effectiveMaxY / 4,
                                1.0,
                              ),
                              verticalInterval:
                                  math
                                      .max(sortedEntries.length ~/ 7, 1)
                                      .toDouble(),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 45,
                                  interval: math.max(
                                    (sortedEntries.length / 6)
                                        .ceil()
                                        .toDouble(),
                                    1,
                                  ),
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= sortedEntries.length ||
                                        value.toInt() < 0) {
                                      return const SizedBox();
                                    }
                                    final date = DateTime.parse(
                                      sortedEntries[value.toInt()].key,
                                    );
                                    return Transform.rotate(
                                      angle: -0.7,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Text(
                                          DateFormat('dd/MM').format(date),
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.color,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: effectiveMaxY / 4,
                                  reservedSize: 50,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        value >= 1000
                                            ? '\$${(value / 1000).toStringAsFixed(1)}k'
                                            : '\$${value.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.color,
                                          fontSize: 11,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                            minX: 0,
                            maxX: (sortedEntries.length - 1).toDouble(),
                            minY: effectiveMinY,
                            maxY: effectiveMaxY * 1.1,
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  sortedEntries.length,
                                  (index) => FlSpot(
                                    index.toDouble(),
                                    sortedEntries[index].value,
                                  ),
                                ),
                                isCurved: true,
                                color: Theme.of(context).colorScheme.primary,
                                barWidth: 2.5,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) =>
                                          FlDotCirclePainter(
                                            radius: 3,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            strokeWidth: 1,
                                            strokeColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.surface,
                                          ),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.2),
                                      Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading:
              () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          error:
              (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar los datos de ventas',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(salesTrendProvider(30)),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
        );
      },
    );
  }

  Widget _buildProductItem(
    ProductStats product,
    ThemeData theme,
    bool isDark, {
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(isDark ? 0.1 : 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          if (product.imageUrl != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    isDark
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.image_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.quantitySold} unidades vendidas',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '\$${product.totalRevenue.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Future<void> _showPeriodSelector() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPeriod = ref.read(selectedPeriodProvider);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Seleccionar período',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Últimos 7 días'),
                  onTap: () {
                    final now = DateTime.now();
                    ref.read(selectedPeriodProvider.notifier).state = (
                      startDate: now.subtract(const Duration(days: 7)),
                      endDate: now,
                    );
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Últimos 30 días'),
                  onTap: () {
                    final now = DateTime.now();
                    ref.read(selectedPeriodProvider.notifier).state = (
                      startDate: now.subtract(const Duration(days: 30)),
                      endDate: now,
                    );
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Personalizado'),
                  onTap: () async {
                    final dateRange = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: DateTimeRange(
                        start: currentPeriod.startDate,
                        end: currentPeriod.endDate,
                      ),
                      builder: (context, child) {
                        return Theme(
                          data: theme.copyWith(
                            colorScheme: theme.colorScheme.copyWith(
                              primary: theme.colorScheme.primary,
                              onPrimary: theme.colorScheme.onPrimary,
                              surface:
                                  isDark ? Colors.grey[900]! : Colors.white,
                              onSurface: theme.colorScheme.onSurface,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (dateRange != null) {
                      if (!mounted) return;
                      ref.read(selectedPeriodProvider.notifier).state = (
                        startDate: dateRange.start,
                        endDate: dateRange.end,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }
}
