import 'package:flutter/material.dart';
import 'package:flutterapp/providers/web3_auth.provider.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final web3AuthProvider =
        Provider.of<Web3AuthProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: ListTile.divideTiles(context: context, tiles: [
          ListTile(
            title: Text("Account"),
            trailing: Text(
              '''${web3AuthProvider.shortAddress}''',
            ),
          ),
          ListTile(
            title: Text("Language"),
            trailing: Text(
              '''English''',
            ),
          ),
        ]).toList(),
      ),
    );
  }
}
