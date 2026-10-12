import 'package:flutter/material.dart';
import '../../../../core/theme/liturgical_colors.dart';
import '../../../liturgical_calendar/models/liturgical_day.dart';

class TodayLiturgicalCard extends StatelessWidget {
  final LiturgicalDay day;
  final VoidCallback? onOpenCalendar;
  final Function(String reference)? onOpenReading;

  const TodayLiturgicalCard({
    super.key,
    required this.day,
    this.onOpenCalendar,
    this.onOpenReading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = day.color;
    final textColor = LiturgicalColors.getContrastText(cardColor);

    return Container(
      decoration: BoxDecoration(
        gradient: LiturgicalColors.getGradient(cardColor),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Marca de agua sutil de cruz / icono sagrado
            Positioned(
              right: -15,
              bottom: -15,
              child: Opacity(
                opacity: 0.12,
                child: Icon(
                  Icons.auto_stories,
                  size: 150,
                  color: textColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado superior: Tiempo litúrgico y Rango
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 13, color: textColor),
                            const SizedBox(width: 6),
                            Text(
                              'HOY • ${day.tiempo.toUpperCase()}',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Ciclo ${day.cicloDominical} • Año ${day.cicloFerial}',
                          style: TextStyle(
                            color: textColor.withOpacity(0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Celebración del día
                  Text(
                    day.celebracion,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    'Color litúrgico: ${day.colorNombre[0].toUpperCase()}${day.colorNombre.substring(1)} (${day.rango})',
                    style: TextStyle(
                      color: textColor.withOpacity(0.85),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Referencias de las lecturas del día (solo referencias según requerimiento MVP)
                  Text(
                    'Lecturas del Día:',
                    style: TextStyle(
                      color: textColor.withOpacity(0.95),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: day.lecturas.map((lectura) {
                      return InkWell(
                        onTap: () => onOpenReading?.call(lectura.referencia),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: textColor.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                lectura.tipo == 'evangelio' ? Icons.menu_book_rounded : Icons.bookmark_outline,
                                size: 14,
                                color: textColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${lectura.tipoTitulo}: ${lectura.referencia}',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Botón al calendario completo
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onOpenCalendar,
                      style: TextButton.styleFrom(
                        foregroundColor: textColor,
                        backgroundColor: textColor.withOpacity(0.12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('Ver mes litúrgico', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
