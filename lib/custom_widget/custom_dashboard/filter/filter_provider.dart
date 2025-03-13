import 'package:flutter/material.dart';

enum FilterType { weekly, monthly, yearly, all }

class FilterProvider with ChangeNotifier {
  FilterType _selectedFilter = FilterType.all;
  DateTime? _weeklyStartDate;
  DateTime? _weeklyEndDate;
  int? _selectedYear;
  int? _selectedMonth;

  FilterType get selectedFilter => _selectedFilter;
  DateTime? get weeklyStartDate => _weeklyStartDate;
  DateTime? get weeklyEndDate => _weeklyEndDate;
  int? get selectedYear => _selectedYear;
  int? get selectedMonth => _selectedMonth;

  void setFilter(FilterType filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setWeeklyRange(DateTime startDate, DateTime endDate) {
    _weeklyStartDate = startDate;
    _weeklyEndDate = endDate;
    _selectedFilter = FilterType.weekly;
    notifyListeners();
  }

  void setMonthYear(int year, int month) {
    _selectedYear = year;
    _selectedMonth = month;
    _selectedFilter = FilterType.monthly;
    notifyListeners();
  }

  void setYear(int year) {
    _selectedYear = year;
    _selectedFilter = FilterType.yearly;
    notifyListeners();
  }
}
