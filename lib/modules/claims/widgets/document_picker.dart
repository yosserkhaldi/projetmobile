import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:mon_constat_digital/core/state/app_scope.dart';

typedef PickedFile = ({String name, String? path});

/// Ouvre le sélecteur de fichiers. Remplaçable dans les tests.
Future<PickedFile?> Function() pickDocument = () async {
  final files = await FilePicker.pickFiles();
  if (files.isEmpty) return null;
  final file = files.first;
  return (name: file.name, path: kIsWeb ? null : file.path);
};

/// Télécharge un fichier du dossier et propose de l'enregistrer.
Future<void> saveFromServer(
  BuildContext context, {
  required String kind,
  required String id,
  required String name,
}) async {
  final sync = AppScope.of(context).claimsSync;
  if (sync == null) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final bytes = await sync.api.download(kind, id, sync.identity);
    await FilePicker.saveFile(fileName: name, bytes: bytes);
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Fichier indisponible pour le moment.')),
    );
  }
}
