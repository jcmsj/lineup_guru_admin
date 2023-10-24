import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'queue_list.dart';
import 'page_title_widget.dart';
import 'server_url_widget.dart';
import 'package:provider/provider.dart';

// Create a ChangeNotifier for a nullable ShopQueue variable with an extra field my number
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
}

Future<ShopQueue> pollQueue(String url, String name) async {
  // Get ServerURL from ServerUrlNotifier
  final response = await http.get(Uri.parse('$url/queue/$name'));
  if (response.statusCode == 200) {
    // body -> json -> Update queueNotifier
    return ShopQueue.fromJson(jsonDecode(response.body));
  }

  throw Exception(
    'Failed to fetch queue. Reason: ${response.body}',
  );
}

Future<int> joinQueue(ShopQueue q, String url) async {
  final response = await http.post(
    Uri.parse('$url/join/${q.id}'),
  );
  if (response.statusCode == 200) {
    // Do something with the response body
    Map<String, dynamic> result = jsonDecode(response.body);
    return result['number'];
  } else {
    throw Exception('Failed to join queue');
  }
}

class JoinOrQRFab extends StatefulWidget {
  const JoinOrQRFab({super.key});

  @override
  State<JoinOrQRFab> createState() => _JoinOrQRFabState();
}

class _JoinOrQRFabState extends State<JoinOrQRFab> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<QueueNotifier, ServerUrlNotifier>(
        builder: (context, queueNotifier, serverUrlNotifier, child) {
      if (queueNotifier.queue == null) {
        return const CircularProgressIndicator();
      } else if (queueNotifier._myNumber > 0) {
        return FloatingActionButton.extended(
          onPressed: () {},
          label: const Text("Show QR Code"),
          icon: const Icon(Icons.qr_code),
        );
      }

      return FloatingActionButton.extended(
          disabledElevation: 0,
          onPressed: () async {
            queueNotifier.setMyNumber(await joinQueue(
              queueNotifier.queue!,
              serverUrlNotifier.serverUrl == ""
                  ? "http://lineup-gu.ru.larkspur.website"
                  : serverUrlNotifier.serverUrl,
            ));
            queueNotifier.setQueue(await pollQueue(
              serverUrlNotifier.serverUrl,
              queueNotifier.queue!.name,
            ));
          },
          label: const Text("Join Queue"),
          icon: const Icon(Icons.add));
    });
  }
}

// Create a State class that contains the ShopQueue field
// class _SecondRouteState extends State<SecondRoute> {
class SecondRoute extends StatefulWidget {
  const SecondRoute({super.key});

  @override
  State<SecondRoute> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  // Poll server for latest queue every 2 seconds
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      print("polling queue");
      Provider.of<QueueNotifier>(context, listen: false).setQueue(
        await pollQueue(
            Provider.of<ServerUrlNotifier>(context, listen: false).serverUrl,
            Provider.of<QueueNotifier>(context, listen: false).queue!.name),
      );
    });
  }

  @override // CANCAEL THE TIMER!!
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<QueueNotifier, ServerUrlNotifier>(
        builder: (context, queueNotifier, serverUrlNotifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Queue  Details"),
        ),
        floatingActionButton: const JoinOrQRFab(),
        body: Center(
          child: Column(
            children: [
              PageTitleWidget(title: "Queue: ${queueNotifier.queue?.name}"),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        "Currently Serving:",
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        "# ${queueNotifier.queue?.current}",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text("Last Number in Queue:",
                          style: TextStyle(fontSize: 20)),
                      Text(
                        "# ${queueNotifier.queue?.lastPosition}",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text("Status:"),
                        queueNotifier._myNumber < 0
                            ? const Text("Not in queue",
                                style: TextStyle(fontSize: 20))
                            : Text(
                                "You are # ${queueNotifier._myNumber}",
                                style: const TextStyle(fontSize: 20),
                              ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      );
    });
  }
}
