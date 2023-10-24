import 'package:flutter/material.dart';

class PageTitleWidget extends StatefulWidget {
  final String title;
  const PageTitleWidget({Key? key, required this.title}) : super(key: key);

  @override
  PageTitleState createState() => PageTitleState();
}

class PageTitleState extends State<PageTitleWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 84, 84, 84),
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            height: 1.5,
            width: 500,
            color: const Color.fromARGB(255, 255, 189, 89),
          ),
        ],
      ),
    );
  }
}
