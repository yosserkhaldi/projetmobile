import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/theme/app_theme.dart';

/// Couleurs des graphiques du module 5, à la manière de Grafana : la
/// palette de l'application reste celle des écrans, ces teintes ne servent
/// qu'aux tracés et aux seuils.
abstract final class ClaimsColors {
  // Seuils : bon, à surveiller, critique. Le bleu sert d'information.
  static const ok = Color(0xFF56A64B);
  static const warn = Color(0xFFE0B400);
  static const critical = Color(0xFFE02F44);
  static const info = Color(0xFF3274D9);

  /// Séries catégorielles, ordre de la palette classique de Grafana.
  static const series = [
    Color(0xFF7EB26D),
    Color(0xFFEAB839),
    Color(0xFF6ED0E0),
    Color(0xFFEF843C),
    Color(0xFFE24D42),
    Color(0xFF1F78C1),
    Color(0xFFBA43A9),
    Color(0xFF705DA0),
  ];

  /// Couleur d'un score selon les seuils 30 et 60.
  static Color threshold(num score, {num warnAt = 30, num criticalAt = 60}) =>
      score >= criticalAt
      ? critical
      : score >= warnAt
      ? warn
      : ok;
}

const _radius = 12.0;

/// Trait de lumière fin, posé en haut d'une surface : il donne l'arête
/// éclairée d'une pièce encrée, sans lueur ni ombre colorée.
class LitEdge extends StatelessWidget {
  const LitEdge({this.opacity = .28, this.inset = 12, super.key});
  final double opacity, inset;

  @override
  Widget build(BuildContext context) => Positioned(
    top: 0,
    left: inset,
    right: inset,
    height: 1,
    child: IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0),
              Colors.white.withValues(alpha: opacity),
              Colors.white.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _litBackground(
  BuildContext context,
  Set<WidgetState> states,
  Widget? child, {
  required double opacity,
}) => Stack(
  fit: StackFit.passthrough,
  children: [
    ?child,
    if (!states.contains(WidgetState.disabled)) LitEdge(opacity: opacity),
  ],
);

/// Thème des écrans du module 5 : boutons plus fins avec une arête
/// éclairée, titres en 600 au plus, filets discrets. Les couleurs restent
/// celles de [AppPalette].
class ClaimsStyle extends StatelessWidget {
  const ClaimsStyle({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final dark = theme.brightness == Brightness.dark;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
    );
    const label = TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );
    return Theme(
      data: theme.copyWith(
        appBarTheme: theme.appBarTheme.copyWith(
          // La police d'affichage n'existe qu'en 800 : titres en Manrope.
          titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0,
          ),
        ),
        cardTheme: CardThemeData(
          color: p.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: p.borderSoft),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        dividerTheme: DividerThemeData(color: p.borderSoft, space: 24),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: shape,
            textStyle: label,
            elevation: 0,
            backgroundBuilder: (context, states, child) =>
                _litBackground(context, states, child, opacity: .32),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            foregroundColor: p.text,
            side: BorderSide(color: p.border),
            shape: shape,
            textStyle: label,
            backgroundBuilder: (context, states, child) =>
                _litBackground(context, states, child, opacity: dark ? .12 : 0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: p.primaryText,
            textStyle: label.copyWith(fontSize: 14),
            shape: shape,
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: SegmentedButton.styleFrom(
            textStyle: label.copyWith(fontSize: 14),
            side: BorderSide(color: p.border),
            selectedBackgroundColor: p.primaryTint,
            selectedForegroundColor: p.primaryText,
            shape: shape,
          ),
        ),
        chipTheme: theme.chipTheme.copyWith(
          backgroundColor: p.surface,
          side: BorderSide(color: p.borderSoft),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          labelStyle: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: p.text,
          ),
          iconTheme: IconThemeData(color: p.textMuted, size: 16),
        ),
        listTileTheme: theme.listTileTheme.copyWith(
          titleTextStyle: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: p.text,
          ),
          subtitleTextStyle: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 13,
            color: p.textMuted,
          ),
          iconColor: p.textMuted,
        ),
      ),
      child: child,
    );
  }
}

/// Surface encrée : fond de la palette, filet fin, arête éclairée.
///
/// [ink] prend le bleu nuit de la palette (`hero`) : c'est le seul bloc
/// sombre d'un écran, celui que l'œil trouve d'abord.
class InkPanel extends StatelessWidget {
  const InkPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.ink = false,
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool ink;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ink ? p.hero : p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ink ? Colors.white.withValues(alpha: .08) : p.borderSoft,
        ),
        boxShadow: ink
            ? const [
                BoxShadow(
                  color: Color(0x140B1626),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Padding(padding: padding, child: child),
          LitEdge(opacity: ink ? .30 : 0, inset: 20),
        ],
      ),
    );
  }
}

/// Titre de section : taille et couleur, pas de graisse lourde.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {this.trailing, super.key});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: context.palette.text,
            ),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// Bande horizontale qui défile : regroupe des blocs courts sur une ligne
/// au lieu de les empiler. Tous les enfants sont construits (pas de liste
/// paresseuse) : ils restent trouvables et accessibles.
class XStrip extends StatelessWidget {
  const XStrip({
    required this.children,
    this.gap = 8,
    this.padding = EdgeInsets.zero,
    super.key,
  });
  final List<Widget> children;
  final double gap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: padding,
    clipBehavior: Clip.none,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0) SizedBox(width: gap),
          child,
        ],
      ],
    ),
  );
}

/// Pastille de couleur d'une série ou d'un seuil.
class SeriesDot extends StatelessWidget {
  const SeriesDot(this.color, {this.size = 8, super.key});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

/// Étiquette discrète : texte coloré sur un fond très pâle, coins de 6.
class QuietTag extends StatelessWidget {
  const QuietTag(this.text, {required this.color, this.dot, super.key});
  final String text;
  final Color color;

  /// Couleur d'une pastille devant le texte, pour un seuil.
  final Color? dot;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot != null) ...[
          SeriesDot(dot!, size: 6),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
