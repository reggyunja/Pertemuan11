import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Get, Post, Edit, Delete',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String apiUrl = "https://jsonplaceholder.typicode.com/posts";
  late List data;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        data = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future postData(String title, String body) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'title': title,
        'body': body,
        'userId': 1,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      fetchData(); // Refresh data after successful post
    } else {
      throw Exception('Failed to create data');
    }
  }

  Future updateData(int id, String title, String body) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$id'),
      body: jsonEncode({
        'id': id,
        'title': title,
        'body': body,
        'userId': 1,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      fetchData(); // Refresh data after successful update
    } else {
      throw Exception('Failed to update data');
    }
  }

  Future deleteData(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      fetchData(); // Refresh data after successful delete
    } else {
      throw Exception('Failed to delete data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reggy Unjaya - 32210095'),
      ),
      body: ListView.builder(
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(data[index]['title']),
            subtitle: Text(data[index]['body']),
            onTap: () {
              // Implement edit or delete functionality here
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Edit/Delete Data'),
                    content: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Implement edit functionality
                            Navigator.pop(context); // Close the dialog
                            // Show another dialog for editing
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return EditDialog(
                                  id: data[index]['id'],
                                  title: data[index]['title'],
                                  body: data[index]['body'],
                                  onEdit: (title, body) {
                                    updateData(data[index]['id'], title, body);
                                  },
                                );
                              },
                            );
                          },
                          child: Text('Edit'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Implement delete functionality
                            Navigator.pop(context); // Close the dialog
                            deleteData(data[index]['id']);
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add functionality
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddDialog(
                onAdd: (title, body) {
                  postData(title, body);
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddDialog extends StatelessWidget {
  final Function(String, String) onAdd;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  AddDialog({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Data'),
      content: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: bodyController,
            decoration: InputDecoration(labelText: 'Body'),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onAdd(titleController.text, bodyController.text);
            Navigator.pop(context); // Close the dialog
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class EditDialog extends StatelessWidget {
  final int id;
  final String title;
  final String body;
  final Function(String, String) onEdit;
  final TextEditingController titleController;
  final TextEditingController bodyController;

  EditDialog({
    required this.id,
    required this.title,
    required this.body,
    required this.onEdit,
  })  : titleController = TextEditingController(text: title),
        bodyController = TextEditingController(text: body);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Data'),
      content: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: bodyController,
            decoration: InputDecoration(labelText: 'Body'),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onEdit(titleController.text, bodyController.text);
            Navigator.pop(context); // Close the dialog
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
