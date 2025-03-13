import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> items = [];
  bool isLoading = true;
  String baseUrl = "";

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String ipServidor = prefs.getString('api_server_ip') ?? '';
    final String port = prefs.getString('api_server_port') ?? '';
    final String accessToken = prefs.getString('access_token') ?? '';

    baseUrl = "$ipServidor:$port";

    final response = await http.get(
      Uri.parse('https://$baseUrl/client/byprofessional?skip=0&take=5'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        items = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]['title']),
                  subtitle: Text(items[index]['body']),
                );
              },
            ),
    );
  }
}
