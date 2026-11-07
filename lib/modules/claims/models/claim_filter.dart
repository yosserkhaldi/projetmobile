import 'package:flutter/material.dart' show DateTimeRange;

import 'package:mon_constat_digital/modules/claims/models/claim.dart';

/// Filtres de la liste des sinistres : texte, statut, gravité et date.
class ClaimFilter {
  const ClaimFilter({this.query = '', this.status, this.severity, this.dates});

  static const severities = ['Matériel', 'Léger', 'Grave'];

  final String query;
  final String? status, severity;
  final DateTimeRange? dates;

  bool matches(Claim claim) {
    final text = query.trim().toLowerCase();
    if (text.isNotEmpty &&
        ![
          claim.id,
          claim.status,
          claim.severity,
          claim.place,
          claim.type,
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
