import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'NotificationService.dart';
import 'MedicationModel.dart';
import 'notification_storage.dart';

class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];

  List<Medication> get medications =>
      _medications..sort((a, b) => a.time.compareTo(b.time));

  List<Medication> get takenMedications =>
      _medications.where((med) => med.isTaken).toList();

  void addMedication(String name, String dose, DateTime time) {
    final newMed = Medication(
      id: _medications.length + 1,
      name: name,
      dose: dose,
      time: time,
    );
    _medications.add(newMed);
    NotificationService().scheduleNotification(newMed.id, name, dose, time);
    notifyListeners();
  }

  void toggleTaken(int id) {
    final index = _medications.indexWhere((med) => med.id == id);
    if (index != -1) {
      _medications[index].isTaken = !_medications[index].isTaken;
      notifyListeners();
    }
  }
}
