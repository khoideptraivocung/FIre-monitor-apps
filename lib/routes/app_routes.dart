import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String main = '/main';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      main: (context) => const MainScreen(),
    };
  }
}
