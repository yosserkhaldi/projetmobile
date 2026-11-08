import 'package:mon_constat_digital/modules/claims/models/claim_insight.dart';
import 'package:mon_constat_digital/modules/claims/models/claim_status.dart';

class ClaimDocument {
  const ClaimDocument({
    required this.id,
    required this.name,
    this.path,
    this.kind = ClaimDocument.supporting,
    this.requestId,
    this.analysis,
    this.analysisJson,
  });

  static const supporting = 'Pièce';
  static const expertReport = "Rapport d'expertise";

  /// Jointes d'office par la déclaration (module 3).
  static const photo = 'Photo';
  static const video = 'Vidéo';
  static const voiceNote = 'Note vocale';
  static const accidentReport = 'Constat amiable';

  final String id, name, kind;
  final String? path, requestId;

  /// Réservé à l'agent : le serveur ne l'envoie pas au conducteur.
  final DocumentAnalysis? analysis;
  final String? analysisJson;
}

class DocumentRequest {
  const DocumentRequest({
    required this.id,
    required this.label,
    this.note = '',
    this.documentId,
  });

  static const labels = ['Devis', 'Facture', 'PV de police', 'Autre'];

  final String id, label, note;
  final String? documentId;

  bool get isOpen => documentId == null;

  DocumentRequest fulfilledBy(String id) =>
      DocumentRequest(id: this.id, label: label, note: note, documentId: id);
}

class Claim {
  Claim({
    required this.id,
    required this.type,
    required this.place,
    required this.date,
    this.status = ClaimStatus.draft,
    this.severity = 'Matériel',
    this.observations = '',
    this.agentName,
    this.expertName,
    this.expertAppointment,
    this.expertPhone,
    this.expertPlace,
    this.expertKind,
    this.appointmentState,
    this.appointmentBy,
    this.appointmentNote,
    this.responsibility,
    this.indemnity,
    this.decisionReason,
  });
  final String id;
  String type, place, date, status, severity, observations;
  String? agentName, expertName, decisionReason;
  DateTime? expertAppointment;

  /// Rendez-vous d'expertise : lieu, téléphone de l'expert, et nature,
  /// « Véhicule » ou « Corporelle » (examen médical d'un blessé).
  String? expertPhone, expertPlace, expertKind;

  /// « proposed » ou « accepted ». [appointmentBy] : `agent` ou `driver`,
  /// l'auteur du dernier créneau proposé. [appointmentNote] l'accompagne.
  String? appointmentState, appointmentBy, appointmentNote;

  bool get appointmentConfirmed => appointmentState == 'accepted';

  /// Vrai quand [role] doit répondre au créneau proposé par l'autre partie.
  bool awaitsAnswerFrom(String role) =>
      status == ClaimStatus.expertise &&
      expertAppointment != null &&
      appointmentState == 'proposed' &&
      appointmentBy != role;

  /// Part de responsabilité du conducteur A, en pourcentage.
  int? responsibility;

  /// Montant d'indemnisation en TND.
  double? indemnity;

  final List<String> timeline = ['Brouillon créé'];

  /// Date de chaque étape, par position dans [timeline].
  final Map<int, DateTime> timelineDates = {};
  final List<ClaimDocument> documents = [];
  final List<DocumentRequest> requests = [];
  final List<String> circumstances = [];
  final List<String> impactZones = [];

  Iterable<DocumentRequest> get openRequests =>
      requests.where((request) => request.isOpen);

  /// Date de l'accident. [date] vient de deux formats selon sa source.
  DateTime? get occurredAt {
    final french = RegExp(
      r'^(\d{2})/(\d{2})/(\d{4})(?: (\d{2}):(\d{2}))?',
    ).firstMatch(date);
    if (french == null) return DateTime.tryParse(date);
    int part(int index) => int.parse(french[index] ?? '0');
    return DateTime(part(3), part(2), part(1), part(4), part(5));
  }

  /// Reprend l'état de [other], sans changer d'objet : les écrans ouverts
  /// gardent leur référence.
  void updateFrom(Claim other) {
    type = other.type;
    place = other.place;
    date = other.date;
    status = other.status;
    severity = other.severity;
    observations = other.observations;
    agentName = other.agentName;
    expertName = other.expertName;
    expertAppointment = other.expertAppointment;
    expertPhone = other.expertPhone;
    expertPlace = other.expertPlace;
    expertKind = other.expertKind;
    appointmentState = other.appointmentState;
    appointmentBy = other.appointmentBy;
    appointmentNote = other.appointmentNote;
    responsibility = other.responsibility;
    indemnity = other.indemnity;
    decisionReason = other.decisionReason;
    timeline
      ..clear()
      ..addAll(other.timeline);
    timelineDates
      ..clear()
      ..addAll(other.timelineDates);
    documents
      ..clear()
      ..addAll(other.documents);
    requests
      ..clear()
      ..addAll(other.requests);
    circumstances
      ..clear()
      ..addAll(other.circumstances);
    impactZones
      ..clear()
      ..addAll(other.impactZones);
  }

  /// Copie figée, pour écrire en base l'état du dossier à un instant donné.
  Claim snapshot() =>
      Claim(
          id: id,
          type: type,
          place: place,
          date: date,
          status: status,
          severity: severity,
          observations: observations,
          agentName: agentName,
          expertName: expertName,
          expertAppointment: expertAppointment,
          expertPhone: expertPhone,
          expertPlace: expertPlace,
          expertKind: expertKind,
          appointmentState: appointmentState,
          appointmentBy: appointmentBy,
          appointmentNote: appointmentNote,
          responsibility: responsibility,
          indemnity: indemnity,
          decisionReason: decisionReason,
        )
        ..timeline.clear()
        ..timeline.addAll(timeline)
        ..documents.addAll(documents)
        ..requests.addAll(requests)
        ..circumstances.addAll(circumstances)
        ..impactZones.addAll(impactZones);
}
