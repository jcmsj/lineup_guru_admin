import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'second_route.dart';
import 'package:provider/provider.dart';
import 'server_url_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditQueueScreen extends StatefulWidget {
  const EditQueueScreen({Key? key}) : super(key: key);

  @override
  _EditQueueScreenState createState() => _EditQueueScreenState();
}

class _EditQueueScreenState extends State<EditQueueScreen> {
  final _queueNameController = TextEditingController();
  int _queueCurrent = 0;

  @override
  void initState() {
    super.initState();
    // set the queue name and current number from the queueNotifier
    final queueNotifier = Provider.of<QueueNotifier>(context, listen: false);
    _queueNameController.text = queueNotifier.queue!.name;
    _queueCurrent = queueNotifier.queue!.current;
  }

  // Create a updateQueue method
  Future<void> updateQueue() async {
    final newName = _queueNameController.text;
    final queueNotifier = Provider.of<QueueNotifier>(context, listen: false);
    final serverUrl =
        Provider.of<ServerUrlNotifier>(context, listen: false).serverUrl;
    final response = await http.post(
      Uri.parse('$serverUrl/update/${queueNotifier.queue!.id}'),
      body: {
        'name': newName,
        'current': _queueCurrent.toString(),
        'icon': queueNotifier.queue!.iconName,
        'last_position': queueNotifier.queue!.lastPosition.toString(),
        'created_at': queueNotifier.queue!.createdAt.toString(),
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      showSavedToast();
    }
  }

  void showSavedToast() {
    Fluttertoast.showToast(
        msg: "Queue has been updated",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<QueueNotifier, ServerUrlNotifier>(
      builder: (BuildContext context, QueueNotifier model,
          ServerUrlNotifier server, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Queue'),
          ),
          floatingActionButton: (_queueCurrent == model.queue?.current)
              // || (_queueNameController.text == model.queue?.name)
              ? null
              : FloatingActionButton.extended(
                  onPressed: updateQueue,
                  label: const Text('Save'),
                  icon: const Icon(Icons.save),
                ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Queue Name:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                TextField(
                  style: const TextStyle(color: Colors.black),
                  controller: _queueNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter queue name',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Current Queue Number:',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _queueCurrent--;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _queueCurrent.toString(),
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _queueCurrent++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
