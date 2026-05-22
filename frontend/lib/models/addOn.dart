import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddOnItem {
  final String name;
  final double price;
  final IconData icon;

  const AddOnItem({
    required this.name,
    required this.price,
    required this.icon,
  });
}
