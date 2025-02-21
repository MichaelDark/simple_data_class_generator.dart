// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DataClassGenerator
// **************************************************************************

class Person {
  const Person({
    required this.name,
    required this.age,
  });

  final String name;

  final String age;

  Person copyWith({
    String? name,
    String? age,
  }) {
    return Person(
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }
}
