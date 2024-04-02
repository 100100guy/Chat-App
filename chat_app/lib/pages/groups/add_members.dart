import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/components/mydrawer.dart';
import 'package:chat_app/pages/groups/group_chat_page.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_service.dart';
import 'package:chat_app/services/groups/group_chat_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class AddMembersInGroup extends StatefulWidget {
  const AddMembersInGroup({Key? key}) : super(key: key);

  @override
  _AddMembersInGroupState createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _groupService = GroupChatService();
  final _chatService = ChatService();
  final TextEditingController _search = TextEditingController();
  final TextEditingController _groupName = TextEditingController();
  List<Map<String, dynamic>> memberList = [];
  Map<String, dynamic>? userMap;
  StreamController<List<Map<String, dynamic>>> _searchStreamController =
      StreamController<List<Map<String, dynamic>>>();

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
    _search.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    _searchStreamController.close();
    super.dispose();
  }

  void getCurrentUserDetails() async {
    await _firestore
        .collection('Users')
        .doc(_authService.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        memberList.add({
          "name": value['name'],
          "email": value['email'],
          "uid": value['uid'],
          "isAdmin": true,
        });
      });
    });
  }

  void _onSearchChanged() {
    _searchStreamController.add([]);
    if (_search.text.isNotEmpty) {
      searchUser(_search.text);
    }
  }

  void searchUser(String query) async {
    await _firestore
        .collection('Users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email',
            isLessThan: query +
                '\uf8ff') // unicode character to make it lexicographically correct
        .get()
        .then((value) {
      List<Map<String, dynamic>> results = [];
      value.docs.forEach((doc) {
        results.add({
          "name": doc['name'],
          "email": doc['email'],
          "uid": doc['uid'],
          "isAdmin": false,
        });
      });
      _searchStreamController.add(results);
    });
  }

  void onResultTap() {
    bool isAlreadyExist = false;
    for (var i = 0; i < memberList.length; i++) {
      if (memberList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }
    if (!isAlreadyExist) {
      setState(() {
        memberList.add(userMap!);
      });
    }

    print(userMap);
  }

  void removeMember(int index) {
    if (memberList[index]['isAdmin'] == false) {
      setState(() {
        memberList.removeAt(index);
      });
    }
    print(memberList);
  }

  void createGroup() async {
    String groupId = Uuid().v1();

    await _firestore.collection('groups').doc(groupId).set({
      "members": memberList,
      "id": groupId,
    });

    for (int i = 0; i < memberList.length; i++) {
      String uid = memberList[i]['uid'];

      await _firestore
          .collection('Users')
          .doc(uid)
          .collection('groups')
          .doc(groupId)
          .set({
        "name": _groupName.text,
        "id": groupId,
      });
    }
    final Timestamp timestamp = Timestamp.now();
    await _firestore.collection('groups').doc(groupId).collection('chats').add({
      "message":
          "${_authService.currentUser!.email.toString()} Created This Group.",
      "type": "notify",
      "timestamp": timestamp,
      "senderID": _authService.currentUser!.uid,
      "senderEmail": _authService.currentUser!.email,
      "receiverID": groupId,
    });

    GoRouter.of(context).go('/groups');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Center(
          child: Text(
            'Add Members',
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // create group
              // GoRouter.of(context).go('/groups');
              //check if members are more than 2
              if (memberList.length > 2) {
                createGroup();
              } else {
                print(memberList);
                //show flutter toast
                Fluttertoast.showToast(
                    msg: "Group should have at least 3 members",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            },
            icon: Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Container(
        child: Column(
          children: [
            // group name
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _groupName,
                decoration: InputDecoration(
                  hintText: 'Group Name',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'Search by email',
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _searchStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(snapshot.data![index]['name']),
                          subtitle: Text(snapshot.data![index]['email']),
                          trailing: IconButton(
                            onPressed: () {
                              userMap = snapshot.data![index];
                              onResultTap();
                            },
                            icon: Icon(Icons.add),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Expanded(
                    child: Center(
                      child: Text("No results found"),
                    ),
                  );
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: memberList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    // padding
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    title: Text(memberList[index]['name']),
                    subtitle: Text(memberList[index]['email']),
                    trailing: IconButton(
                      onPressed: () {
                        removeMember(index);
                      },
                      icon: Icon(Icons.remove),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
