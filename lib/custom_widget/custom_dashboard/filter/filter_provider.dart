import 'package:flutter/material.dart';

enum FilterType { weekly, monthly, yearly, all }

class FilterProvider with ChangeNotifier {
  FilterType _selectedFilter = FilterType.all; // Default filter

  FilterType get selectedFilter => _selectedFilter;

  void setFilter(FilterType filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
}
