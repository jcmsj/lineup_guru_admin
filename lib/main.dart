import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (ctx) => QueueNotifier(),
      ),
      ChangeNotifierProvider(
        create: (ctx) => ServerUrlNotifier(),
      ),
    ],
    child: const MyApp(),
  ));
}

Future<ShopQueue> fetchQueue(String url, String name) async {
  final response = await http.get(Uri.parse('$url/queue/$name'));
  print(response.body);
  if (response.statusCode == 200) {
    // Do something with the response body
    return ShopQueue.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to fetch queue');
  }
}

// create a MyApp class that mimics the layout of lineup_guru_app for an admin version of the app
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Poll the queue every 2 seconds
    Timer.periodic(const Duration(seconds: 2), (timer) {
      final queueNotifier = Provider.of<QueueNotifier>(context, listen: false);
      queueNotifier.pollQueue(
        Provider.of<ServerUrlNotifier>(context, listen: false).serverUrl,
        "sample",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the MaterialApp with a ChangeNotifierProvider for the ServerUrlNotifier
    return ChangeNotifierProvider(
      create: (context) => ServerUrlNotifier(),
      child: MaterialApp(
        title: 'Lineup Guru',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<QueueNotifier>(
          builder: (context, value, child) {
            if (value.queue == null) {
              return const CircularProgressIndicator();
            }

            return EditQueueScreen(queue: value.queue!);
          },
        ),
      ),
    );
  }
}

class ServerUrlNotifier extends ChangeNotifier {
  String _serverUrl = "http://localhost:88";

  String get serverUrl => _serverUrl;

  set serverUrl(String url) {
    _serverUrl = url;
    notifyListeners();
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

class QueueNotifier extends ChangeNotifier {
  ShopQueue? _queue;
  int _myNumber = -1;
  ShopQueue? get queue => _queue;
  int get myNumber => _myNumber;
  void setQueue(ShopQueue queue) {
    _queue = queue;
    notifyListeners();
  }

  void setMyNumber(int myNumber) {
    _myNumber = myNumber;
    notifyListeners();
  }

  void pollQueue(String url, String name) async {
    // Get ServerURL from ServerUrlNotifier
    final response = await http.get(Uri.parse('$url/queue/$name'));
    if (response.statusCode == 200) {
      // body -> json -> Update queueNotifier
      setQueue(ShopQueue.fromJson(jsonDecode(response.body)));
    } else {
      print(
        'Failed to fetch queue. Reason: ${response.body}',
      );
    }
  }
}

class QueueAdmin extends StatefulWidget {
  @override
  _QueueAdminState createState() => _QueueAdminState();
}

class _QueueAdminState extends State<QueueAdmin> {
  final _queueNotifier = QueueNotifier();
  final _queueNameController = TextEditingController();
  // ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Admin'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Add Queue'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Add Queue'),
                    content: TextField(
                      controller: _queueNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter queue name',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final queueName = _queueNameController.text;
                          final response = await http.post(
                            Uri.parse('https://example.com/api/queues'),
                            body: {'name': queueName},
                          );
                          if (response.statusCode == 201) {
                            final queue = ShopQueue.fromJson(
                              jsonDecode(response.body),
                            );
                            _queueNotifier.setQueue(queue);
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: const Text('Edit Queue'),
            onTap: () {
              // TODO: Implement editing queue
            },
          ),
        ],
      ),
    );
  }
}

class EditQueueScreen extends StatefulWidget {
  final ShopQueue queue;

  const EditQueueScreen({Key? key, required this.queue}) : super(key: key);

  @override
  _EditQueueScreenState createState() => _EditQueueScreenState();
}

class _EditQueueScreenState extends State<EditQueueScreen> {
  final _queueNameController = TextEditingController();
  int _queueCurrent = 0;

  @override
  void initState() {
    super.initState();
    _queueNameController.text = widget.queue.name;
    _queueCurrent = widget.queue.current;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Queue'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Queue Name',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _queueNameController,
              decoration: const InputDecoration(
                hintText: 'Enter queue name',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Current Queue Number',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _queueCurrent--;
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                Text(
                  _queueCurrent.toString(),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _queueCurrent++;
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<ServerUrlNotifier>(
              builder: (BuildContext context, ServerUrlNotifier value,
                  Widget? child) {
                return ElevatedButton(
                  onPressed: () async {
                    final queueName = _queueNameController.text;
                    print(value.serverUrl);
                    final response = await http.post(
                      Uri.parse('${value.serverUrl}/update/${widget.queue.id}'),
                      body: {
                        'name': queueName,
                        'current': _queueCurrent.toString(),
                        'icon': widget.queue.iconName,
                        'last_position': widget.queue.lastPosition.toString(),
                        'created_at': widget.queue.createdAt.toString(),
                      },
                    );
                    print(response.body);
                    if (response.statusCode == 200) {}
                  },
                  child: const Text('Save'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
