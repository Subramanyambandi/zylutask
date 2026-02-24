class Employee {
  final int id;
  final String name;
  final DateTime joiningDate;
  final bool isActive;
  final double years;
  final bool isSeniorActive;

  Employee({
    required this.id,
    required this.name,
    required this.joiningDate,
    required this.isActive,
    required this.years,
    required this.isSeniorActive,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      joiningDate: DateTime.parse(json['joining_date']),
      isActive: json['is_active'],
      years: (json['years'] as num).toDouble(),
      isSeniorActive: json['is_senior_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'joining_date': joiningDate.toIso8601String(),
      'is_active': isActive,
      'years': years,
      'is_senior_active': isSeniorActive,
    };
  }
}
