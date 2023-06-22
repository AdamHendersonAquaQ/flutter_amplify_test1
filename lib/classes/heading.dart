enum Comparator { isEqual, isNotEqual, isBetween, isNotBetween }

class Heading {
  final String label;
  final String name;
  final String headingType;
  final String valueType;
  Comparator? comparator;
  String value;
  String? value2;

  Heading({
    required this.label,
    required this.name,
    required this.headingType,
    required this.valueType,
    required this.value,
    this.value2,
    this.comparator,
  });

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'value2': value2,
    };
  }
}
