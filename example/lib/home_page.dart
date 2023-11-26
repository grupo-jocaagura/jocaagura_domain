import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const <Widget>[
          Text('Examples availables'),
          SizedBox(
            height: 16,
          ),
          _ListTile(
            label: 'UserModel',
            model: defaultUserModel,
          ),
          _ListTile(
            label: 'AddressModel',
            model: defaultAddressModel,
          ),
        ],
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.label,
    required this.model,
  });

  final String label;
  final Model model;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        model.toString(),
      ),
    );
  }
}
