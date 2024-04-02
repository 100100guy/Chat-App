import 'package:chat_app/pages/groups/add_new_members.dart';
import 'package:chat_app/pages/home.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName;
  const GroupInfo({required this.groupId, required this.groupName, Key? key})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  List membersList = [];
  bool isAdmin = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // add code to check admin status and get group members
    checkAdminStatus();
    getGroupMembers();
    print(membersList);
  }

  bool checkAdminStatus() {
    bool isAdmin = false;

    membersList.forEach((element) {
      if (element['uid'] == _authService.currentUser!.uid) {
        isAdmin = element['isAdmin'];
      }
    });
    return isAdmin;
  }

  void getGroupMembers() async {
    // add code to get group members
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((value) {
      setState(() {
        membersList = List.from(value['members']);
      });
    });
  }

  Future onLeaveGroup() async {
    if (!checkAdminStatus()) {
      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['uid'] == _authService.currentUser!.uid) {
          membersList.removeAt(i);
        }
      }

      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      Timestamp timestamp = Timestamp.now();
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('chats')
          .add({
        "message":
            "${_authService.currentUser!.email.toString()} Left The Group.",
        "type": "notify",
        "timestamp": timestamp,
        "senderID": _authService.currentUser!.uid,
        "senderEmail": _authService.currentUser!.email,
        "receiverID": widget.groupId,
      });

      await _firestore
          .collection('Users')
          .doc(_authService.currentUser!.uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      GoRouter.of(context).go('/auth_gate');
    }
  }

  void onRemoveMember(int idx) async {
    // add code to remove member
    print('Remove member');

    String removedMembername = membersList[idx]['name'];
    String removedMemberUid = membersList[idx]['uid'];

    setState(() {
      membersList.removeAt(idx);
    });

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    }).then((value) async {
      await _firestore
          .collection('Users')
          .doc(removedMemberUid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();
    });

    Timestamp timestamp = Timestamp.now();
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .collection('chats')
        .add({
      "message": "${removedMembername} Removed From The Group.",
      "type": "notify",
      "timestamp": timestamp,
      "senderID": _authService.currentUser!.uid,
      "senderEmail": _authService.currentUser!.email,
      "receiverID": widget.groupId,
    });

    GoRouter.of(context).go('/auth_gate');
  }

  void onRemoveMemberDialog(int idx) {
    // add code to show dialog to remove member

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Member'),
          content: Text(
              'Are you sure you want to remove ${membersList[idx]['name']} from the group?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )),
            ),
            TextButton(
              onPressed: () {
                onRemoveMember(idx);
                Navigator.pop(context);
              },
              child: Text('Remove',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  )),
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0), // Add padding around the row
              child: Row(
                children: [
                  Container(
                    width:
                        60, // Set the width to control the diameter of the circle
                    height:
                        60, // Set the height to control the diameter of the circle
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Wrap the icon with a circle
                      border: Border.all(
                          color: Colors.grey), // Add border around the circle
                    ),
                    padding: EdgeInsets.all(8), // Add padding inside the circle
                    child: Icon(
                      Icons.group,
                      size: 30,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ), // Group icon
                  ),
                  SizedBox(width: 16), // Add some spacing between icon and text
                  Text(
                    widget.groupName,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ), // Larger font size
                  ),
                ],
              ),
            ),
            SizedBox(height: 16), // Add some spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Total Members: ${membersList.length}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
            if (checkAdminStatus()) ...[
              SizedBox(height: 16), // Add some spacing
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      onPressed: () {
                        // Add member functionality
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => AddNewMembersInGroup(
                                    groupId: widget.groupId,
                                    groupName: widget.groupName,
                                  )),
                        );
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        // Add member functionality
                      },
                      child: Text('Add Member',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 16), // Add some spacing
            ListView.builder(
              shrinkWrap: true,
              itemCount: membersList.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    membersList[index]['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        membersList[index]['email'],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      if (membersList[index]['isAdmin'])
                        Text(
                          'Admin',
                          style: TextStyle(
                            color: Colors.blue, // Example color for admin label
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else if (!membersList[index]['isAdmin'] &&
                          checkAdminStatus())
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              8, 0, 0, 0), // Add padding to move the button
                          child: TextButton(
                            onPressed: () {
                              // Remove member functionality
                              onRemoveMemberDialog(index);
                            },
                            child: Text(
                              'Remove',
                              style: TextStyle(
                                color: Colors
                                    .red, // Example color for remove button
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            // Leave group button leave icon first, then leave group text
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.red, // Example color for leave group icon
                    ),
                    onPressed: () {
                      // Leave group functionality
                      onLeaveGroup();
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      // Leave group functionality
                      onLeaveGroup();
                    },
                    child: Text('Leave Group',
                        style: TextStyle(
                            color: Colors
                                .red, // Example color for leave group text
                            fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
