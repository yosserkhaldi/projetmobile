import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_pdf_service.dart';
import 'package:mon_constat_digital/modules/claims/models/claim.dart';

typedef DeclarationFile = ({
  String name,
  String kind,
  String? path,
  Uint8List? bytes,
});

/// Ce que la déclaration (module 3) apporte au dossier : les photos de
/// preuve, la vidéo, la note vocale et le constat en PDF.
///
/// À appeler avant d'effacer le brouillon. Un PDF impossible à produire
/// (sur le web, par exemple) n'empêche pas d'envoyer le reste.
Future<List<DeclarationFile>> declarationFiles(
  AccidentDraft draft, {
  Future<Uint8List> Function(AccidentDraft draft)? buildPdf,
}) async {
  final files = <DeclarationFile>[
    for (final MapEntry(key: label, value: path) in draft.evidencePaths.entries)
      if (path != null && path.isNotEmpty)
        (
          name: '$label${p.extension(path)}',
          kind: ClaimDocument.photo,
          path: path,
          bytes: null,
        ),
    if (draft.videoPath.isNotEmpty)
      (
        name: 'Vidéo de la scène${p.extension(draft.videoPath)}',
        kind: ClaimDocument.video,
        path: draft.videoPath,
        bytes: null,
      ),
    if (draft.voiceNotePath.isNotEmpty)
      (
        name: 'Note vocale${p.extension(draft.voiceNotePath)}',
        kind: ClaimDocument.voiceNote,
        path: draft.voiceNotePath,
        bytes: null,
      ),
  ];
  try {
    final pdf = await (buildPdf ?? AccidentPdfService().build)(draft);
    files.add((
      name: 'Constat amiable.pdf',
      kind: ClaimDocument.accidentReport,
      path: null,
      bytes: pdf,
    ));
  } catch (error) {
    debugPrint('Constat PDF non joint : $error');
  }
  return files;
}
