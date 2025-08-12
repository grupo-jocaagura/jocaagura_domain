import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'session_demo_page.dart';

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
          const _ListTile(
            label: 'UserModel',
            model: defaultUserModel,
          ),
          const _ListTile(
            label: 'AddressModel',
            model: defaultAddressModel,
          ),
          const _ListTile(
            label: 'StoreModel',
            model: defaultStoreModel,
          ),
          ListTile(
            title: const Text('Bloc Session demo'),
            leading: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SessionDemoPage(),
                ),
              );
            },
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
