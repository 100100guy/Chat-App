import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/components/mydrawer.dart';
import 'package:chat_app/themes/dark_mode.dart';
import 'package:chat_app/themes/light_mode.dart';
import 'package:chat_app/themes/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Center(
          child: Text(
            'Settings', // Changed title to 'Settings'
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
        iconTheme: Theme.of(context)
            .iconTheme
            .copyWith(color: Theme.of(context).colorScheme.inversePrimary),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.logout,
                color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        padding: EdgeInsets.all(20.0), // Added padding for spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondary, // Background color of the container
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: 20.0,
                    ),
                  ),
                  CupertinoSwitch(
                    value: Provider.of<ThemeProvider>(context).isDarkMode(),
                    onChanged: (value) {
                      if (value) {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .setTheme(darkMode);
                      } else {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .setTheme(lightMode);
                      }
                    },
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
