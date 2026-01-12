import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/authentication/widgets/auth_gate.dart';

void main() {
  runApp(const ProviderScope(child: CampusConnectApp()));
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Connect',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
