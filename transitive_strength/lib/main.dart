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
      title: 'Crypto Pairs App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CryptoPairsPage(),
    );
  }
}

class CryptoPairsPage extends StatefulWidget {
  @override
  _CryptoPairsPageState createState() => _CryptoPairsPageState();
}

class _CryptoPairsPageState extends State<CryptoPairsPage> {
  List<Map<String, String>> cryptoPairs = [];
  final _formKey = GlobalKey<FormState>();
  String fromCrypto = '';
  String toCrypto = '';

  void _addPair() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        cryptoPairs.add({'from': fromCrypto, 'to': toCrypto});
      });
    }
  }

  void _submitPairs() async {
    final url = 'http://localhost:8080/api/submit_pairs';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'pairs': cryptoPairs}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pairs submitted successfully!')),
      );
      setState(() {
        cryptoPairs.clear();
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
                        fromCrypto = value!;
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
                        toCrypto = value!;
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
                itemCount: cryptoPairs.length,
                itemBuilder: (context, index) {
                  final pair = cryptoPairs[index];
                  return ListTile(
                    title: Text('${pair['from']} -> ${pair['to']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          cryptoPairs.removeAt(index);
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
