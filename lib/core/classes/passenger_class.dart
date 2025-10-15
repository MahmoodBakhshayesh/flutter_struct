class Passenger {
  final String id;
  final String firstName;
  final String lastName;
  final String nationality;
  final String passportNo;
  final DateTime birthDate;

  Passenger({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.nationality,
    required this.passportNo,
    required this.birthDate,
  });

  Passenger copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? nationality,
    String? passportNo,
    DateTime? birthDate,
  }) =>
      Passenger(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        nationality: nationality ?? this.nationality,
        passportNo: passportNo ?? this.passportNo,
        birthDate: birthDate ?? this.birthDate,
      );

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
    id: json["id"].toString(),
    firstName: json["firstName"],
    lastName: json["lastName"],
    nationality: json["nationality"],
    passportNo: json["passportNo"],
    birthDate: DateTime.parse(json["birthDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "nationality": nationality,
    "passportNo": passportNo,
    "birthDate": "${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}",
  };
}
