import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../models/thematic_suggestion.dart';

class ThematicSuggestionsWidget extends ConsumerStatefulWidget {
  final Function(String reference)? onOpenReading;

  const ThematicSuggestionsWidget({
    super.key,
    this.onOpenReading,
  });

  @override
  ConsumerState<ThematicSuggestionsWidget> createState() =>
      _ThematicSuggestionsWidgetState();
}

class _ThematicSuggestionsWidgetState
    extends ConsumerState<ThematicSuggestionsWidget> {
  ThematicCategoryType _selectedCategory = ThematicCategoryType.amor;
  final ScrollController _scrollController = ScrollController();
  bool _canScrollRight = true;
  bool _canScrollLeft = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollArrows);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollArrows());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollArrows);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollArrows() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    final nextRight = maxScroll > 4 && offset < maxScroll - 8;
    final nextLeft = offset > 8;
    if (nextRight != _canScrollRight || nextLeft != _canScrollLeft) {
      setState(() {
        _canScrollRight = nextRight;
        _canScrollLeft = nextLeft;
      });
    }
  }

  void _scrollRight() {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + 210.0)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollLeft() {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset - 210.0)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final suggestions = ref.watch(dailyThematicSuggestionsProvider);

    // Encontrar la sugerencia activa seleccionada
    final currentSuggestion = suggestions.firstWhere(
      (s) => s.category == _selectedCategory,
      orElse: () => suggestions.first,
    );

    final catColor = currentSuggestion.category.color;
    final surfaceBg = isDark ? const Color(0xFF1A1C21) : const Color(0xFFFCF9F2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF23201A),
                  const Color(0xFF191B20),
                ]
              : [
                  const Color(0xFFFFF8E8),
                  const Color(0xFFFDFBF7),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryGold.withValues(alpha: 0.35),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withValues(alpha: isDark ? 0.06 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado atractivo de la sección
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryGold,
                          AppTheme.primaryGold.withValues(alpha: 0.75),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GUÍA BÍBLICA PARA TU DÍA',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppTheme.primaryGold,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          fontSize: 12.5,
                        ),
                      ),
                      Text(
                        'Luz de la Palabra para tu corazón hoy',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '5 temas',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Barra horizontal de categorías con flechas indicadoras para móvil
          SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: _canScrollLeft ? 34 : 0,
                    right: _canScrollRight ? 34 : 0,
                  ),
                  itemCount: ThematicCategoryType.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = ThematicCategoryType.values[index];
                    final isSelected = cat == _selectedCategory;
                    final pillColor = cat.color;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: ChoiceChip(
                        avatar: Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                        label: Text(
                          cat.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: pillColor,
                        backgroundColor: isDark
                            ? const Color(0xFF252830)
                            : const Color(0xFFF2ECE1),
                        elevation: isSelected ? 3 : 0,
                        pressElevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? pillColor
                                : (isDark ? Colors.white12 : Colors.black12),
                          ),
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                      ),
                    );
                  },
                ),

                // Flecha izquierda cuando se ha desplazado
                if (_canScrollLeft)
                  Positioned(
                    left: 0,
                    child: GestureDetector(
                      onTap: _scrollLeft,
                      child: Container(
                        height: 36,
                        width: 30,
                        decoration: BoxDecoration(
                          color: surfaceBg.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryGold.withValues(alpha: 0.45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          size: 20,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ),
                  ),

                // Flecha derecha indicadora para pantallas móviles
                if (_canScrollRight)
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: _scrollRight,
                      child: Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          color: surfaceBg.withValues(alpha: 0.96),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryGold.withValues(alpha: 0.55),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(-2, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

        // Tarjeta devocional interactiva del tema seleccionado
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey(currentSuggestion.category),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2024) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: catColor.withOpacity(0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: catColor.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior: Categoría activa y Cita bíblica
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            currentSuggestion.category.icon,
                            size: 14,
                            color: catColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            currentSuggestion.category.title.toUpperCase(),
                            style: TextStyle(
                              color: catColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge con la referencia bíblica
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            catColor,
                            catColor.withOpacity(0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: catColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_stories_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            currentSuggestion.referencia,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Lema / Frase inspiradora
                Text(
                  '"${currentSuggestion.lema}"',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 17,
                    height: 1.3,
                    color: isDark ? const Color(0xFFF5E6C8) : const Color(0xFF4A3419),
                  ),
                ),
                const SizedBox(height: 8),

                // Reflexión de vida para el día
                Text(
                  currentSuggestion.reflexion,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // Contexto bíblico del pasaje
                Text(
                  'Origen: ${currentSuggestion.contexto}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white38 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 16),

                // Botón interactivo para abrir y leer el pasaje completo
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onOpenReading?.call(currentSuggestion.referencia);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: catColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.menu_book_rounded, size: 16),
                    label: const Text(
                      'Leer pasaje bíblico',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }
}
