import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:senior_project/pages/auth_page.dart';
import 'package:senior_project/pages/setting/friends_page.dart';
import 'package:senior_project/pages/setting/friends_provider.dart';
import 'package:senior_project/pages/setting/setting.dart';
import 'firebase_options.dart';
import 'package:senior_project/pages/expense/expense_page.dart';
import 'package:senior_project/pages/income/income_page.dart';
import 'package:senior_project/pages/login.dart';
import 'package:senior_project/pages/dashboard/dashboard.dart';
import 'package:senior_project/pages/signup.dart';
import 'package:provider/provider.dart';
import 'package:senior_project/pages/expense/expense_data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('initializing firebase donnnnnnnnnnnneeeeeeee');
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ExpenseDataProvider(),
        ),
        ChangeNotifierProvider(
          // Add FriendsProvider here
          create: (context) => FriendsProvider(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xffFFC145),
        ),
        home: const AuthPage(),
        routes: {
          '/login': (context) => const Login(),
          '/signup': (context) => const Signup(),
          '/dashboard': (context) => const Dashboard(),
          '/income': (context) => IncomePage(),
          '/expense': (context) => ExpensePage(),
          '/setting': (context) => const Setting(),
          '/friends': (context) => FriendsPage(),
        },
      ),
    );
  }
}
