import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/liturgical_colors.dart';
import '../../bible/presentation/search_screen.dart';
import '../data/liturgical_calculator.dart';
import '../models/liturgical_day.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  final List<String> _weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  final List<String> _monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime.utc(now.year, now.month, 1);
    _selectedDate = DateTime.utc(now.year, now.month, now.day);
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime.utc(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime.utc(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedDayInfo = LiturgicalCalculator.getLiturgicalDay(_selectedDate);

    // Días del mes actual
    final daysInMonth = DateTime.utc(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final firstWeekday = _displayedMonth.weekday; // 1 = Lunes, 7 = Domingo

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver a Inicio',
          onPressed: () => ref.read(homeTabIndexProvider.notifier).setTab(0),
        ),
        title: const Text('Calendario Litúrgico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: 'Ir a Hoy',
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _displayedMonth = DateTime.utc(now.year, now.month, 1);
                _selectedDate = DateTime.utc(now.year, now.month, now.day);
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de mes y año
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2024) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: _prevMonth,
                    ),
                    Text(
                      '${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Encabezado de días de la semana
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _weekdays.map((w) {
                  return SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        w,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),

              // Matriz de calendario con colores litúrgicos
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1.0,
                ),
                itemCount: 42, // 6 semanas
                itemBuilder: (context, index) {
                  final dayOffset = index - (firstWeekday - 1);
                  if (dayOffset < 0 || dayOffset >= daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final dayNum = dayOffset + 1;
                  final dayDate = DateTime.utc(_displayedMonth.year, _displayedMonth.month, dayNum);
                  final isSelected = dayDate.isAtSameMomentAs(_selectedDate);
                  final isToday = dayDate.year == DateTime.now().year &&
                      dayDate.month == DateTime.now().month &&
                      dayDate.day == DateTime.now().day;

                  final litDay = LiturgicalCalculator.getLiturgicalDay(dayDate);
                  final color = litDay.color;

                  return InkWell(
                    onTap: () => setState(() => _selectedDate = dayDate),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.25)
                            : (isDark ? const Color(0xFF1E2024) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : (isToday ? Colors.amber : Colors.transparent),
                          width: isSelected || isToday ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Punto indicador del color litúrgico oficial
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Tarjeta de detalle del día litúrgico seleccionado
              _buildSelectedDayDetail(context, selectedDayInfo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayDetail(BuildContext context, LiturgicalDay day) {
    final cardColor = day.color;

    final textColor = LiturgicalColors.getContrastText(cardColor);

    return Container(
      decoration: BoxDecoration(
        gradient: LiturgicalColors.getGradient(cardColor),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: cardColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${day.fecha.day} de ${_monthNames[day.fecha.month - 1]} de ${day.fecha.year}',
                style: TextStyle(
                  color: textColor.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${day.tiempo} (${day.colorNombre})',
                  style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            day.celebracion,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Grado: ${day.rango.toUpperCase()} • Ciclo ${day.cicloDominical} • Año ${day.cicloFerial}',
            style: TextStyle(color: textColor.withOpacity(0.85), fontSize: 12),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 6),
          Text(
            'Referencias bíblicas asignadas:',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Column(
            children: day.lecturas.map((l) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchScreen(initialQuery: l.referencia),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${l.tipoTitulo}: ${l.referencia}',
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Icon(Icons.open_in_new_rounded, size: 16, color: textColor),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
