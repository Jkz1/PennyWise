import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final IconData icon;

  CategoryItem(this.name, this.icon);
}

final List<CategoryItem> categories_expenses = [
  CategoryItem("Food", Icons.restaurant),
  CategoryItem("Transport", Icons.directions_car),
  CategoryItem("Shopping", Icons.shopping_bag),
  CategoryItem("Bills", Icons.receipt_long),
  CategoryItem("Health", Icons.medical_services),
];

final List<CategoryItem> categories_income = [
  CategoryItem("Salary", Icons.attach_money),
  CategoryItem("Business", Icons.business_center),
  CategoryItem("Investment", Icons.trending_up),
  CategoryItem("Gift", Icons.card_giftcard),
];