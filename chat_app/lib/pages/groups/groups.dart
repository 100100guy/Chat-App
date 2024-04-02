// group chat main screen contains a list of groups

import 'package:chat_app/components/mydrawer.dart';
import 'package:chat_app/pages/groups/add_members.dart';
import 'package:chat_app/pages/groups/group_chat_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:chat_app/services/groups/group_chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> with WidgetsBindingObserver {
  final _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _groupService = GroupChatService();
  List _groups = [];

  void logout() {
    final _authService = AuthService();
    _authService.signOut();
    _authService.setOnlineStatus('offline');
    GoRouter.of(context).go('/auth_gate');
  }

  @override
  void initState() {
    super.initState();
    getGroups();
    WidgetsBinding.instance!.addObserver(this);
  }

  void getGroups() async {
    String uid = _authService.currentUser!.uid;
    await _firestore
        .collection('Users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        _groups = value.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Center(
            child: Text(
              'Groups',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                logout();
              },
              icon: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ],
        ),
        drawer: MyDrawer(),
        body: Container(
          margin:
              EdgeInsets.only(top: 5), // Add 5px gap between app bar and body
          child: ListView.builder(
            itemCount: _groups.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => GroupChatPage(
                              name: _groups[index]['name'],
                              gcid: _groups[index]['id'])),
                    );
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
                              _groups[index]['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary,
                              ),
                            ),
                          ),
                          leading: Padding(
                            padding: EdgeInsets.only(
                                top: 8.0), // Add space above the leading icon
                            child: Icon(Icons.group,
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
        // a button at the bottom of the screen to create a new group, circles with a plus sign, elevated button
        floatingActionButton: ElevatedButton(
          onPressed: () {
            // GoRouter.of(context).go('/create_group');
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddMembersInGroup()),
            );
          },

          //decoration
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
          ),
          child: Icon(Icons.add,
              color: Theme.of(context).colorScheme.inversePrimary),
        ));
  }
}
