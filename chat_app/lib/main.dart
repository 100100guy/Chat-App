import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/auth/auth_gate.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/pages/home.dart';
import 'package:chat_app/pages/login.dart';
import 'package:chat_app/pages/register.dart';
import 'package:chat_app/themes/light_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final GoRouter router = GoRouter(initialLocation: "/auth_gate", routes: [
    GoRoute(path: "/login", builder: ((context, state) => const LoginPage())),
    GoRoute(
        path: "/register", builder: ((context, state) => const RegisterPage())),
    GoRoute(
        path: "/auth_gate", builder: ((context, state) => const AuthGate())),
    GoRoute(path: "/home", builder: ((context, state) => const HomePage())),
    GoRoute(
      path: "/chat/:email/:uid",
      builder: ((context, state) {
        final String email = state.pathParameters['email']!;
        final String uid = state.pathParameters['uid']!;
        print(email + " " + uid);
        return ChatPage(email: email!, uid: uid!);
      }),
    ),
  ]);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: lightMode,
      // home: RegisterPage(),
      routerConfig: router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
