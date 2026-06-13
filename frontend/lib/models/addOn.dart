import 'package:flutter/material.dart';

class AddOnItem {
  final int id;
  final String name;
  final double price;
  final IconData icon;

  const AddOnItem({
    this.id = 0,
    required this.name,
    required this.price,
    required this.icon,
  });
}
