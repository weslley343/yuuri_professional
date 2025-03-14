import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yuuri_professional/pages/client/client.dart';
import 'package:yuuri_professional/pages/home/menu.dart'; // Import the menu.dart file

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> items = [];
  bool isLoading = true;
  bool isFetchingMore = false;
  String baseUrl = "";
  int skip = 0;
  final int take = 5;

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
      Uri.parse('http://$baseUrl/client/byprofessional?skip=$skip&take=$take'),
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

  Future<void> fetchMoreItems() async {
    setState(() {
      isFetchingMore = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final String ipServidor = prefs.getString('api_server_ip') ?? '';
    final String port = prefs.getString('api_server_port') ?? '';
    final String accessToken = prefs.getString('access_token') ?? '';

    baseUrl = "$ipServidor:$port";
    skip += take;

    final response = await http.get(
      Uri.parse('http://$baseUrl/client/byprofessional?skip=$skip&take=$take'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        items.addAll(json.decode(response.body));
        isFetchingMore = false;
      });
    } else {
      throw Exception('Failed to load more items');
    }
  }

  void _loadNextPage() {
    setState(() {
      skip += take;
      fetchItems();
    });
  }

  void _loadPreviousPage() {
    if (skip >= take) {
      setState(() {
        skip -= take;
        fetchItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Menu(), // Add the Drawer here
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('No items available'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final color = item['gender'] == 'male'
                              ? Colors.blue
                              : const Color.fromARGB(255, 255, 122, 122);
                          return Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        item['full_name']
                                            .split(' ')
                                            .take(2)
                                            .join(' '),
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      subtitle: Text(
                                        "@ ${item['identifier']}",
                                        style: TextStyle(
                                          color: color,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Client(),
                                            ),
                                          );
                                        },
                                        child: const Icon(Icons.arrow_downward),
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Add your logic for the new button here
                                        },
                                        child: const Text('Acessar'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _loadPreviousPage,
                          child: const Text('<'),
                        ),
                        Text('Page ${skip ~/ take + 1}'),
                        TextButton(
                          onPressed: _loadNextPage,
                          child: const Text('>'),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
