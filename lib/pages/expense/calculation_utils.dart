// calculation_utils.dart

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:senior_project/pages/expense/expense_data_provider.dart'; // Adjust the import path

class CalculationUtils {
  static List<Map<String, dynamic>> getPaymentTransactions(
      BuildContext context) {
    final expenseProvider =
        Provider.of<ExpenseDataProvider>(context, listen: false);
    final payersData = expenseProvider.payersData;
    final billsAmounts = expenseProvider.billsAmounts;

    Map<String, double> balances = calculateBalances(payersData, billsAmounts);
    return _generatePaymentTransactions(balances);
  }

  static Map<String, double> calculateBalances(
      List<Map<String, dynamic>> payersData,
      List<Map<String, dynamic>> billsAmounts) {
    Map<String, double> balances = {};

    for (var bill in billsAmounts) {
      String personName = bill['name'];
      double individualBillAmount = bill['amount'];

      double amountPaid = 0.0;
      for (var payer in payersData) {
        if (payer['payer'] == personName) {
          amountPaid = payer['amountPaid'];
          break;
        }
      }

      balances[personName] = amountPaid - individualBillAmount;
    }

    return balances;
  }

  static List<Map<String, dynamic>> _generatePaymentTransactions(
      Map<String, double> balances) {
    List<Map<String, dynamic>> owed = [];
    List<Map<String, dynamic>> owe = [];
    List<Map<String, dynamic>> transactions = [];

    // Separate owed and owe
    balances.forEach((person, balance) {
      if (balance > 0) {
        owed.add({'person': person, 'amount': balance});
      } else if (balance < 0) {
        owe.add({'person': person, 'amount': balance.abs()});
      }
    });

    // Match owe to owed
    for (var owePerson in owe) {
      String oweName = owePerson['person'];
      double oweAmount = owePerson['amount'];

      // Create a copy of the owed list to iterate over
      List<Map<String, dynamic>> owedCopy = List.from(owed);

      for (var owedPerson in owedCopy) {
        String owedName = owedPerson['person'];
        double owedAmount = owedPerson['amount'];

        if (oweAmount <= owedAmount) {
          transactions.add({
            'payer': oweName,
            'payee': owedName,
            'amount': oweAmount,
          });
          owed.firstWhere((p) => p['person'] == owedName)['amount'] -=
              oweAmount;
          oweAmount = 0;
          break;
        } else {
          transactions.add({
            'payer': oweName,
            'payee': owedName,
            'amount': owedAmount,
          });
          oweAmount -= owedAmount;
          owed.firstWhere((p) => p['person'] == owedName)['amount'] = 0;
          owed.removeWhere((p) => p['person'] == owedName);
          if (owed.isEmpty) {
            break;
          }
        }
      }
    }

    return transactions;
  }
}
