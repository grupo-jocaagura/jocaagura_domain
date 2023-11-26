import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const Text('Examples availables'),
          const SizedBox(
            height: 16,
          ),
          Text(
            defaultUserModel.toString(),
          ),
        ],
      ),
    );
  }
}
