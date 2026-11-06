import 'package:flutter/foundation.dart';

import 'package:mon_constat_digital/modules/accident/models/accident_draft.dart';

class AccidentStore extends ChangeNotifier {
  AccidentDraft? draft;
  int currentStep = 0;

  void saveDraft(AccidentDraft value, int step) {
    draft = value;
    currentStep = step;
    value.touch();
    notifyListeners();
  }

  AccidentDraft startNew() {
    draft = AccidentDraft();
    currentStep = 0;
    notifyListeners();
    return draft!;
  }

  void clearDraft() {
    draft = null;
    currentStep = 0;
    notifyListeners();
  }
}
