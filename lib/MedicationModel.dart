class Medication {
  int id;
  String name;
  String dose;
  DateTime time;
  bool isTaken;

  Medication({
    required this.id,
    required this.name,
    required this.dose,
    required this.time,
    this.isTaken = false,
  });
}
