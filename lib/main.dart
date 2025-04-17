import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import 'package:senior_project/pages/auth_page.dart';
import 'package:senior_project/pages/login.dart';
import 'package:senior_project/pages/signup.dart';
import 'package:senior_project/pages/dashboard/dashboard.dart';
import 'package:senior_project/pages/income/income_page.dart';
import 'package:senior_project/pages/expense/expense_page.dart';
import 'package:senior_project/pages/setting/setting.dart';
import 'package:senior_project/pages/setting/friends_page.dart';
import 'package:senior_project/notification/notification_page.dart';
import 'package:senior_project/notification/notifiction_service.dart';

import 'package:senior_project/pages/expense/expense_data_provider.dart';
import 'package:senior_project/pages/setting/friends_provider.dart';
import 'package:senior_project/custom_widget/custom_dashboard/filter/filter_provider.dart';

import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // You can also report errors to Firebase or Sentry here
  };

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().initializeNotifications();

  runZonedGuarded(() {
    runApp(const MainApp());
  }, (error, stackTrace) {
    // Catches errors that crash the app
    print('Uncaught zone error: $error');
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ExpenseDataProvider()),
        ChangeNotifierProvider(create: (context) => FriendsProvider()),
        ChangeNotifierProvider(create: (context) => FilterProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xffFFC145),
        ),
        home: const AuthPage(),
        builder: (context, child) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Center(
              child: Text(
                'Something went wrong 🧨',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          };
          return child!;
        },
        routes: {
          '/login': (context) => const Login(),
          '/signup': (context) => const Signup(),
          '/dashboard': (context) => const Dashboard(),
          '/income': (context) => const IncomePage(),
          '/expense': (context) => const ExpensePage(),
          '/setting': (context) => const Setting(),
          '/friends': (context) => FriendsPage(),
          '/notifications': (context) => const NotificationPage(),
        },
      ),
    );
  }
}
