import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yuuri_professional/pages/client/client.dart';
import 'package:yuuri_professional/pages/home/home.dart';
import 'package:yuuri_professional/pages/signin/signin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Signin(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => Home(),
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) => Client(),
      ),
    ],
  );

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData temaEscuro = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        color: Color.fromARGB(255, 0, 0, 0),
      ),
      useMaterial3: true,
    );

    return MaterialApp.router(
      theme: temaEscuro,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
