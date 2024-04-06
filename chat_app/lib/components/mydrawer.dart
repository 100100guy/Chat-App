import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/themes/dark_mode.dart';
import 'package:chat_app/themes/light_mode.dart';
import 'package:chat_app/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(BuildContext context) {
    final _authService = AuthService();
    _authService.signOut();
    _authService.setOnlineStatus('offline');
    GoRouter.of(context).go('/auth_gate');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        // drawer icon color
        backgroundColor: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 100, 0, 50),
              child: Center(
                child: Icon(
                  Icons.message,
                  size: 100,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),

            Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                child: ListTile(
                  title: Text('H O M E',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                  leading: Icon(Icons.home,
                      color: Theme.of(context).colorScheme.inversePrimary),
                  onTap: () {
                    GoRouter.of(context).pop();
                    GoRouter.of(context).push('/home');
                  },
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                child: ListTile(
                  title: Text('G R O U P S',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                  leading: Icon(Icons.group,
                      color: Theme.of(context).colorScheme.inversePrimary),
                  onTap: () {
                    GoRouter.of(context).pop();
                    GoRouter.of(context).push('/groups');
                  },
                )),
            // settings
            Padding(
                padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                child: ListTile(
                  title: Text('S E T T I N G S',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary)),
                  leading: Icon(Icons.settings,
                      color: Theme.of(context).colorScheme.inversePrimary),
                  onTap: () {
                    GoRouter.of(context).pop();
                    GoRouter.of(context).push('/settings');
                  },
                )),
            // logout
            Padding(
              padding: EdgeInsets.fromLTRB(25, 400, 0, 0),
              child: ListTile(
                title: Text('L O G O U T',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary)),
                leading: Icon(Icons.logout,
                    color: Theme.of(context).colorScheme.inversePrimary),
                onTap: () => logout(context),
              ),
            ),
          ],
        ));
  }
}
