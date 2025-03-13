import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _apiServerIpController = TextEditingController();
  final TextEditingController _apiServerPortController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final sharedPrefs = await SharedPreferences.getInstance();

    setState(() {
      _apiServerIpController.text =
          sharedPrefs.getString('api_server_ip') ?? '';
      _apiServerPortController.text =
          sharedPrefs.getString('api_server_port') ?? '';
      _emailController.text = sharedPrefs.getString('email') ?? '';
      _passwordController.text = sharedPrefs.getString('password') ?? '';
    });
  }

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final apiServerIp = _apiServerIpController.text;
    final apiServerPort = _apiServerPortController.text;

    final loginSuccessful = await getTokens(
      apiServerIp,
      apiServerPort,
      email,
      password,
    );

    if (!mounted) return;

    if (loginSuccessful) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao realizar login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(27),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _apiServerIpController,
              decoration: const InputDecoration(labelText: 'API Server IP'),
            ),
            TextField(
              controller: _apiServerPortController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'API Server Port'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Conectar'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> getTokens(
  String apiServerIp,
  String apiServerPort,
  String email,
  String password,
) async {
  final loginUrl = Uri.parse('http://$apiServerIp:$apiServerPort/professional/signin');

  final requestBody = json.encode({
    'email': email,
    'password': password,
  });

  final response = await http.post(
    loginUrl,
    headers: {'Content-Type': 'application/json'},
    body: requestBody,
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);

    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString('access_token', responseBody['acetoken']);
    await sharedPrefs.setString('refresh_token', responseBody['reftoken']);
    await sharedPrefs.setString('email', email);
    await sharedPrefs.setString('api_server_ip', apiServerIp);
    await sharedPrefs.setString('api_server_port', apiServerPort);
    await sharedPrefs.setString('password', password);

    return true;
  } else {
    return false;
  }
}
