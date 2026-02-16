import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  CategoryItem(this.name, this.icon, this.color);
}

final List<CategoryItem> categories_expenses = [
  CategoryItem("Food", Icons.restaurant, Colors.orangeAccent),
  CategoryItem("Transport", Icons.directions_car, Colors.blueAccent),
  CategoryItem("Shopping", Icons.shopping_bag, Colors.pinkAccent),
  CategoryItem("Bills", Icons.receipt_long, Colors.greenAccent),
  CategoryItem("Health", Icons.medical_services, Colors.redAccent),
  CategoryItem("Other", Icons.more_horiz, Colors.grey),
];

final List<CategoryItem> categories_income = [
  CategoryItem("Salary", Icons.attach_money, Colors.greenAccent),
  CategoryItem("Business", Icons.business_center, Colors.blueAccent),
  CategoryItem("Investment", Icons.trending_up, Colors.purpleAccent),
  CategoryItem("Gift", Icons.card_giftcard, Colors.orangeAccent),
  CategoryItem("Other", Icons.more_horiz, Colors.grey),
];