import 'package:flutter/material.dart' show Color;

class Contact {
  int? id;
  String name;
  String phone;
  Color buttonColor;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.buttonColor,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      buttonColor: Color(int.parse(json['buttonColor'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'buttonColor': buttonColor.value.toString(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'buttonColor': buttonColor.value.toString(),
    };
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, phone: $phone, buttonColor: $buttonColor}';
  }
}
