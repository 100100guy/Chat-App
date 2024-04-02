// create a basic stateful home page

import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/mydrawer.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

// create a state for the home page

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _chatService = ChatService();
  final _authService = AuthService();
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _users = [];

  // create a function to logout
  void logout() {
    // add code to logout
    final _authService = AuthService();
    _authService.signOut();
    _authService.setOnlineStatus('offline');
    GoRouter.of(context).go('/auth_gate');
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _authService.setOnlineStatus('online');
    } else {
      _authService.setOnlineStatus('offline');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color inversePrimaryColor = Theme.of(context).colorScheme.inversePrimary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Center(
          // Centering the text
          child: Text(
            'Home',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              // Changing text color to red (you can choose any color you want)
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout,
                color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ],
      ),

      // add drawer
      drawer: MyDrawer(),

      body: Container(
        margin: EdgeInsets.only(top: 5), // Add 5px gap between app bar and body
        child: ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: InkWell(
                onTap: () {
                  GoRouter.of(context).push(
                      '/chat/${_users[index]['email']}/${_users[index]['uid']}');
                },
                child: SizedBox(
                  height: 90, // Set custom height for the card
                  child: Card(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          20, 4, 10, 4), // Add padding for ListTile
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            vertical:
                                4), // Add more space above and below the content
                        title: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              4, 8, 0, 0), // Add space above the title
                          child: Text(
                            _users[index]['email'],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                        leading: Padding(
                          padding: EdgeInsets.only(
                              top: 8.0), // Add space above the leading icon
                          child: Icon(Icons.person,
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary), // Add leading icon
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
