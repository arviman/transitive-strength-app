import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transitive Pairs App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PairsPage(),
    );
  }
}

class PairsPage extends StatefulWidget {
  @override
  _PairsPageState createState() => _PairsPageState();
}

class _PairsPageState extends State<PairsPage> {
  List<Map<String, String>> pairs = [];
  final _formKey = GlobalKey<FormState>();
  String from = '';
  String to = '';

  void _addPair() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        pairs.add({'from': from, 'to': to});
      });
    }
  }

  void _submitPairs() async {
    final url = 'http://localhost:8080/api/submit_pairs';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'pairs': pairs}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pairs submitted successfully!')),
      );
      setState(() {
        pairs.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit pairs!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crypto Pairs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'From'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a cryptocurrency';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        from = value!;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'To'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a cryptocurrency';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        to = value!;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addPair,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: pairs.length,
                itemBuilder: (context, index) {
                  final pair = pairs[index];
                  return ListTile(
                    title: Text('${pair['from']} -> ${pair['to']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          pairs.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPairs,
              child: Text('Submit Pairs'),
            ),
          ],
        ),
      ),
    );
  }
}
