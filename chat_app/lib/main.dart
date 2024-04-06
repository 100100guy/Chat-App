import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/full_image_screen.dart';
import 'package:chat_app/pages/groups/groups.dart';
import 'package:chat_app/pages/settings.dart';
import 'package:chat_app/services/auth/auth_gate.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/pages/home.dart';
import 'package:chat_app/pages/login.dart';
import 'package:chat_app/pages/register.dart';
import 'package:chat_app/themes/light_mode.dart';
import 'package:chat_app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
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
      path: "/full_image/:imageUrl",
      builder: (context, state) {
        final String imageUrl = state.pathParameters['imageUrl']!;
        return FullScreenImage(imageUrl: imageUrl);
      },
    ),
    GoRoute(
      path: "/chat/:email/:uid",
      builder: ((context, state) {
        final String email = state.pathParameters['email']!;
        final String uid = state.pathParameters['uid']!;
        print(email + " " + uid);
        return ChatPage(email: email!, uid: uid!);
      }),
    ),
    // groups
    GoRoute(path: "/groups", builder: ((context, state) => const GroupsPage())),
    GoRoute(
        path: "/settings", builder: ((context, state) => const SettingsPage())),
  ]);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: Provider.of<ThemeProvider>(context).getTheme(),
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
