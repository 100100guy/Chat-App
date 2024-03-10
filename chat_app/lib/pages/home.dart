// create a basic stateful home page

import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/mydrawer.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

// create a state for the home page

class _HomePageState extends State<HomePage> {
  final _chatService = ChatService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _users = [];

  // create a function to logout
  void logout() {
    // add code to logout
    final _authService = AuthService();
    _authService.signOut();
  }

  @override
  void initState() {
    super.initState();
    _chatService.getChatStream().listen((users) {
      setState(() {
        _users = users;
        _users.removeWhere(
            (user) => user['email'] == _authService.currentUser!.email);
      });
    });

    // remove the current user from the list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
        title: Center(
          // Centering the text
          child: Text(
            'Home',
            style: TextStyle(
              color: Colors
                  .white, // Changing text color to red (you can choose any color you want)
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),

      // add drawer
      drawer: MyDrawer(),

      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
            child: InkWell(
              onTap: () {
                GoRouter.of(context).push(
                    '/chat/${_users[index]['email']}/${_users[index]['uid']}');
              },
              child: Card(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                elevation: 2,
                child: ListTile(
                  title: Text(
                    _users[index]['email'],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  leading: const Icon(Icons.person),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
