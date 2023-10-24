import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'main.dart';
import 'server_url_widget.dart';
import 'edit_queue.dart';
import 'second_route.dart';

// ignore: non_constant_identifier_names
Future<List<ShopQueue>> fetchQueues(String url) async {
  final response = await http.get(Uri.parse('$url/queue'));
  print(response.body);
  if (response.statusCode == 200) {
    // Do something with the response body
    return jsonDecode(response.body)
        .map((data) => ShopQueue.fromJson(data))
        .toList()
        .cast<ShopQueue>();
  } else {
    throw Exception('Failed to fetch queue');
  }
}

class ShopQueue {
  final int id;
  final String name;
  final int current;
  final int lastPosition;
  final String createdAt;
  final String iconName;
  ShopQueue({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.current,
    required this.lastPosition,
    required this.iconName,
  });

  factory ShopQueue.fromJson(Map<String, dynamic> json) {
    return ShopQueue(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
      current: json['current'],
      lastPosition: json['last_position'],
      iconName: json['icon'],
    );
  }
}

// Create a FutureBuilder widget for the queues
Consumer<ServerUrlNotifier> buildFutureBuilderQueues() {
  return Consumer<ServerUrlNotifier>(
    builder: (BuildContext context, ServerUrlNotifier value, Widget? child) {
      return FutureBuilder<List<ShopQueue>>(
        future: fetchQueues(value.serverUrl),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ShopQueue>? data = snapshot.data;
            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 40,
                  crossAxisSpacing: 0,
                ),
                itemCount: data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return QueueItem(data: data[index]);
                });
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return const LoadingQueueWidget();
        },
      );
    },
  );
}

class LoadingQueueWidget extends StatelessWidget {
  const LoadingQueueWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          strokeWidth: 8.0,
          color: Color.fromARGB(255, 255, 189, 89),
        ),
        SizedBox(height: 20),
        Text('Loading Queues...'),
      ],
    );
  }
}

class QueueItem extends StatelessWidget {
  const QueueItem({
    super.key,
    required this.data,
  });
  final ShopQueue data;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("napindot ${data.name}");
        Provider.of<QueueNotifier>(context, listen: false).setQueue(data);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditQueueScreen()),
        );
      },
      child: ServiceCard(data.name, data.iconName),
    );
  }
}
