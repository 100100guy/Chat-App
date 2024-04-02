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

class AddNewMembersInGroup extends StatefulWidget {
  final String groupId, groupName;
  const AddNewMembersInGroup(
      {required this.groupId, required this.groupName, Key? key})
      : super(key: key);

  @override
  _AddNewMembersInGroupState createState() => _AddNewMembersInGroupState();
}

class _AddNewMembersInGroupState extends State<AddNewMembersInGroup> {
  final _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _groupService = GroupChatService();
  final _chatService = ChatService();
  final TextEditingController _search = TextEditingController();
  final TextEditingController _groupName = TextEditingController();
  List<Map<String, dynamic>> initMemberList = [];
  List<Map<String, dynamic>> memberList = [];
  Map<String, dynamic>? userMap;
  StreamController<List<Map<String, dynamic>>> _searchStreamController =
      StreamController<List<Map<String, dynamic>>>();

  @override
  void initState() {
    super.initState();
    getGroupMembers();
    _search.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    _searchStreamController.close();
    memberList.clear();
    initMemberList.clear();
    super.dispose();
  }

  void getGroupMembers() async {
    // add code to get group members
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((value) {
      setState(() {
        memberList = List.from(value['members']);
      });
    });
    setState(() {
      for (var i = 0; i < memberList.length; i++) {
        initMemberList.add(memberList[i]);
      }
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

    print(memberList.length);

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": memberList,
    });

    List<Map<String, dynamic>> newMembers = [];

    // new members are those whose uid is not in initMemberList
    for (var i = 0; i < memberList.length; i++) {
      if (!isMemberinInitList(i)) {
        newMembers.add(memberList[i]);
      }
    }

    for (int i = 0; i < newMembers.length; i++) {
      String uid = newMembers[i]['uid'];

      await _firestore
          .collection('Users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .set({
        "name": widget.groupName,
        "id": widget.groupId,
      });
    }

    final Timestamp timestamp = Timestamp.now();
    for (int i = 0; i < newMembers.length; i++) {
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('chats')
          .add({
        "message":
            "${_authService.currentUser!.email.toString()} Added ${newMembers[i]['name']} to the group.",
        "type": "notify",
        "timestamp": timestamp,
        "senderID": _authService.currentUser!.uid,
        "senderEmail": _authService.currentUser!.email,
        "receiverID": widget.groupId,
      });
    }

    GoRouter.of(context).go('/auth_gate');
  }

  bool isMemberinInitList(int index) {
    print(initMemberList);
    for (var i = 0; i < initMemberList.length; i++) {
      if (initMemberList[i]['uid'] == memberList[index]['uid']) {
        print(initMemberList[i]['name']);
        print(initMemberList[i]['email']);
        return true;
      }
    }
    return false;
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
            Flexible(
              child: ListView.builder(
                itemCount: memberList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    // padding
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    title: Text(memberList[index]['name']),
                    subtitle: Text(memberList[index]['email']),
                    // trailing if memberlist[index] not in initMemberList
                    // trailing: IconButton(
                    //   onPressed: () {
                    //     removeMember(index);
                    //   },
                    //   icon: Icon(Icons.remove),
                    // ),

                    // trailing if memberlist[index] in initMemberList
                    trailing: isMemberinInitList(index)
                        ? null
                        : IconButton(
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
