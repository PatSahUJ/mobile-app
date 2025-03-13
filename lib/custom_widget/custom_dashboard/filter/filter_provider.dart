import 'package:flutter/material.dart';

enum FilterType { weekly, monthly, yearly, all }

class FilterProvider with ChangeNotifier {
  FilterType _selectedFilter = FilterType.all;
  int? _selectedYear;
  int? _selectedMonth;
  DateTime? _weeklyStartDate;
  DateTime? _weeklyEndDate;
  String? _selectedCategory;

  FilterProvider() {
    // Initialize to current month and year on app start
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;
    _setWeeklyRangeToCurrentWeek();
  }

  FilterType get selectedFilter => _selectedFilter;
  int? get selectedYear => _selectedYear;
  int? get selectedMonth => _selectedMonth;
  DateTime? get weeklyStartDate => _weeklyStartDate;
  DateTime? get weeklyEndDate => _weeklyEndDate;
  String? get selectedCategory => _selectedCategory;

  void setFilter(FilterType filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void setMonthYear(int year, int month) {
    _selectedYear = year;
    _selectedMonth = month;
    notifyListeners();
  }

  void setYear(int year) {
    _selectedYear = year;
    notifyListeners();
  }

  void setWeeklyRange(DateTime startDate, DateTime endDate) {
    _weeklyStartDate = startDate;
    _weeklyEndDate = endDate;
    notifyListeners();
  }

  void clearMonthYear() {
    _selectedYear = DateTime.now().year;
    _selectedMonth = DateTime.now().month;
    _setWeeklyRangeToCurrentWeek(); // Reset weekly data to current week
    notifyListeners();
    notifyListeners();
  }

  void _setWeeklyRangeToCurrentWeek() {
    DateTime now = DateTime.now();
    int dayOfWeek = now.weekday; // 1 (Monday) - 7 (Sunday)

    DateTime startDate = now.subtract(Duration(days: dayOfWeek - 1));
    DateTime endDate = startDate.add(const Duration(days: 6));

    _weeklyStartDate = DateTime(startDate.year, startDate.month, startDate.day);
    _weeklyEndDate = DateTime(endDate.year, endDate.month, endDate.day);
  }

  void previousWeek() {
    if (_weeklyStartDate != null && _weeklyEndDate != null) {
      DateTime newStartDate =
          _weeklyStartDate!.subtract(const Duration(days: 7));
      DateTime newEndDate = _weeklyEndDate!.subtract(const Duration(days: 7));
      setWeeklyRange(newStartDate, newEndDate);
    }
  }

  void nextWeek() {
    if (_weeklyStartDate != null && _weeklyEndDate != null) {
      DateTime newStartDate = _weeklyStartDate!.add(const Duration(days: 7));
      DateTime newEndDate = _weeklyEndDate!.add(const Duration(days: 7));
      setWeeklyRange(newStartDate, newEndDate);
    }
  }

  void setSelectedCategory(String? category) {
    // Add this method
    _selectedCategory = category;
    notifyListeners();
  }

  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }
}
