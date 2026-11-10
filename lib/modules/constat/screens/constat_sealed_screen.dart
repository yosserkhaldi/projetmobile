import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

import 'package:mon_constat_digital/core/theme/app_colors.dart';
import 'package:mon_constat_digital/core/theme/app_palette.dart';
import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';
import 'package:mon_constat_digital/modules/accident/services/accident_pdf_service.dart';
import 'package:mon_constat_digital/modules/constat/models/constat.dart';
import 'package:mon_constat_digital/modules/constat/services/constat_crypto_service.dart';

class ConstatSealedScreen extends StatelessWidget {
  const ConstatSealedScreen({
    required this.constat,
    required this.draft,
    this.pdfBytes,
    super.key,
  });

  final Constat constat;
  final AccidentDraft draft;
  final Uint8List? pdfBytes;

  static const _crypto = ConstatCryptoService();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final formattedHash = _crypto.formatHash(constat.sha256Hash);

    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: AppBar(
        title: const Text('Constat scellé'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // Hero card de succès
            Card(
              color: palette.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: palette.borderSoft),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.successBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.successText,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Constat scellé et transmis',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: palette.text,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Document officiel inaltérable signé bilatéralement.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Certification QR Code JWS Hors-Ligne (Zero-Dependency)
            Card(
              color: palette.surface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: palette.borderSoft),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.qr_code_2_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CERTIFICATION HORS-LIGNE (JWS)',
                          style: TextStyle(
                            color: palette.text,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: .6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Scannez ce QR Code pour certifier l’authenticité et l’intégrité du constat sans connexion au serveur.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: palette.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.borderSoft),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: (constat.qrCodeBase64 != null &&
                              constat.qrCodeBase64!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                base64Decode(constat.qrCodeBase64!),
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Container(
                              width: 200,
                              height: 200,
                              color: AppColors.canvas,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner,
                                    size: 64,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'QR Code Certifié',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: AppColors.successText,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Signature ECDSA P-256 certifiée — Zero-Dependency Verification',
                              style: TextStyle(
                                color: AppColors.successText,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Empreinte SHA-256
            Card(
              color: AppColors.ink,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.fingerprint,
                          color: Color(0xFF7FE0CC),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'EMPREINTE DE SÉCURITÉ (SHA-256)',
                            style: TextStyle(
                              color: Color(0xFF7FE0CC),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: .8,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white, size: 18),
                          tooltip: 'Copier l’empreinte',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: constat.sha256Hash));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Empreinte SHA-256 copiée !')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.navy800,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SelectableText(
                        formattedHash,
                        style: const TextStyle(
                          color: AppColors.onDarkStrong,
                          fontFamily: 'JetBrains Mono',
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Cette signature cryptographique certifie que le constat PDF n’a subi aucune modification depuis sa double signature.',
                      style: TextStyle(color: AppColors.onDarkBody, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Récapitulatif Véhicules A & B
            Row(
              children: [
                // Véhicule A (Bleu)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      border: Border.all(color: AppColors.primary.withAlpha(50)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                'A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Véhicule A',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          constat.driverAName.isNotEmpty
                              ? constat.driverAName
                              : 'Conducteur A',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          constat.driverAPlate.isNotEmpty
                              ? constat.driverAPlate
                              : 'Immatriculation A',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          constat.driverAInsurer.isNotEmpty
                              ? constat.driverAInsurer
                              : 'Assurance A',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Véhicule B (Ambre)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      border: Border.all(color: AppColors.accent.withAlpha(80)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: AppColors.accent,
                              child: Text(
                                'B',
                                style: TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Véhicule B',
                              style: TextStyle(
                                color: AppColors.warningText,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          constat.driverBName.isNotEmpty
                              ? constat.driverBName
                              : 'Conducteur B',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          constat.driverBPlate.isNotEmpty
                              ? constat.driverBPlate
                              : 'Immatriculation B',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          constat.driverBInsurer.isNotEmpty
                              ? constat.driverBInsurer
                              : 'Assurance B',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Boutons d'action
            FilledButton.icon(
              onPressed: () => _viewPdf(context),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Consulter l’exemplaire officiel (PDF)'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _sharePdf(context),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Partager le constat scellé'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Retour à l’accueil'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewPdf(BuildContext context) async {
    try {
      final bytes = pdfBytes ?? await AccidentPdfService().build(draft);
      await Printing.layoutPdf(
        name: 'constat-${constat.sha256Hash.substring(0, 8)}.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur aperçu PDF : $e')),
        );
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final bytes = pdfBytes ?? await AccidentPdfService().build(draft);
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'constat-${constat.sha256Hash.substring(0, 8)}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur partage PDF : $e')),
        );
      }
    }
  }
}

