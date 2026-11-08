import 'package:flutter/material.dart' show DateTimeRange;

import 'package:mon_constat_digital/modules/claims/models/claim.dart';

/// Filtres de la liste des sinistres : texte, statut, gravité et date.
class ClaimFilter {
  const ClaimFilter({
    this.query = '',
    this.status,
    this.severity,
    this.dates,
    this.display,
  });

  static const severities = ['Matériel', 'Léger', 'Grave'];

  final String query;
  final String? status, severity;
  final DateTimeRange? dates;

  /// Traduit une valeur enregistrée : la recherche trouve « Submitted »
  /// comme « Transmis ».
  final String Function(String value)? display;

  bool matches(Claim claim) {
    final text = query.trim().toLowerCase();
    final values = [claim.status, claim.severity, claim.type];
    if (text.isNotEmpty &&
        ![
          claim.id,
          claim.place,
          ...values,
          if (display case final translate?) ...values.map(translate),
        ].any((value) => value.toLowerCase().contains(text))) {
      return false;
    }
    if (status != null && claim.status != status) return false;
    if (severity != null && claim.severity != severity) return false;
    if (dates case final range?) {
      final date = claim.occurredAt;
      if (date == null) return false;
      final end = range.end.add(const Duration(days: 1));
      if (date.isBefore(range.start) || !date.isBefore(end)) return false;
    }
    return true;
  }
}
