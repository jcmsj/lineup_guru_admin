import 'package:flutter/material.dart';
import 'server_url_widget.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _Item(child: ServerUrlWidget()),
            SizedBox(height: 50.0),
            _Item(
              child: Text(
                "Manual",
                style: TextStyle(fontSize: 25),
              ),
            ),
            SizedBox(height: 50.0),
            _Item(
              child: Text(
                "App Theme",
                style: TextStyle(fontSize: 25),
              ),
            ),
            SizedBox(height: 50.0),
            _Item(
              child: Text(
                "About Us",
                style: TextStyle(fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final Widget child;

  const _Item({required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 250,
      child: Card(
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
