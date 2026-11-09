import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_constat_digital/l10n/l10n.dart';
import 'package:mon_constat_digital/modules/claims/data/declaration_files.dart';
import 'package:mon_constat_digital/modules/claims/l10n/claims_text.dart';
import 'package:mon_constat_digital/modules/claims/models/responsibility.dart';
import 'package:mon_constat_digital/modules/vehicles/models/vehicle.dart';

Vehicle vehicle(String id, String? companyId, {bool archived = false}) =>
    Vehicle(
      id: id,
      plate: '123 TU $id',
      brand: 'Kia',
      model: 'Picanto',
      year: '2020',
      policy: 'P-$id',
      insurerName: '',
      insuranceExpiry: '2027-01-01',
      companyId: companyId,
      archived: archived,
    );

void main() {
  group('barème avec les cases de A et de B', () {
    // Même tableau que le test du serveur : les deux côtés doivent proposer
    // la même chose.
    const cases = [
      (['Changeait de file'], ['Reculait'], 50, ProposalBasis.both),
      (<String>[], ['Doublait'], 0, ProposalBasis.faultB),
      (['Virait à gauche'], ['En stationnement'], 100, ProposalBasis.parkedB),
      (['En stationnement'], ['Virait à droite'], 0, ProposalBasis.parked),
      (['Changeait de file'], <String>[], 100, ProposalBasis.fault),
      (['En stationnement'], ['En stationnement'], 50, ProposalBasis.unknown),
    ];
    for (final (a, b, share, basis) in cases) {
      test('$a / $b', () {
        final proposal = ResponsibilityProposal.fromBoxes(a, b);
        expect(proposal.driverA, share);
        expect(proposal.basis, basis);
      });
    }

    test('la raison suit la langue', () {
      final en = lookupAppLocalizations(const Locale('en'));
      final ar = lookupAppLocalizations(const Locale('ar'));
      expect(
        en.claimProposalReason(
          ResponsibilityProposal.fromBoxes(['Changeait de file'], ['Reculait']),
        ),
        'A: Changing lanes, B: Reversing. Risky manoeuvres on both sides: shared.',
      );
      expect(
        ar.claimProposalReason(
          ResponsibilityProposal.fromBoxes([], ['En stationnement']),
        ),
        'كانت سيارة B متوقفة.',
      );
      expect(
        ResponsibilityProposal.fromBoxes([], ['Doublait']).reason,
        'Doublait : manœuvre à risque de B.',
      );
    });
  });

  group('compagnie du sinistre', () {
    test('un seul assureur : le sinistre lui va', () {
      expect(
        declarationCompany([vehicle('1', 'star'), vehicle('2', 'star')]),
        'star',
      );
    });

    test('deux assureurs : on ne devine pas', () {
      expect(
        declarationCompany([vehicle('1', 'star'), vehicle('2', 'comar')]),
        isNull,
      );
    });

    test('un véhicule archivé ou sans assureur ne compte pas', () {
      expect(
        declarationCompany([
          vehicle('1', 'star'),
          vehicle('2', 'comar', archived: true),
          vehicle('3', null),
        ]),
        'star',
      );
    });

    test('le véhicule déclaré l’emporte', () {
      expect(
        declarationCompany([
          vehicle('1', 'star'),
          vehicle('2', 'comar'),
        ], vehicleId: '2'),
        'comar',
      );
    });
  });
}
