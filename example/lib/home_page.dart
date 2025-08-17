import 'package:flutter/material.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';

import 'bloc_loading_demo_page.dart';
import 'bloc_onboarding_demo_page.dart';
import 'connectivity_demo_page.dart';
import 'session_demo_page.dart';
import 'ws_database_user_demo_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: <Widget>[
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
          _ListTile(
            label: 'StoreModel',
            model: defaultStoreModel,
          ),
          _NavigatorListTile(
            label: 'BlocSession demo',
            page: SessionDemoPage(),
          ),
          _NavigatorListTile(
            label: 'BlocWsDatabase demo',
            page: WsDatabaseUserDemoPage(),
          ),
          _NavigatorListTile(
            label: 'BlocConnectivity demo',
            page: ConnectivityDemoPage(),
          ),
          _NavigatorListTile(
            label: 'BlocLoading demo',
            page: BlocLoadingDemoPage(),
          ),
          _NavigatorListTile(
            label: 'BlocOnboarding demo',
            page: BlocOnboardingDemoPage(),
          ),
        ],
      ),
    );
  }
}

class _NavigatorListTile extends StatelessWidget {
  const _NavigatorListTile({
    required this.label,
    required this.page,
  });

  final String label;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      leading: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => page,
          ),
        );
      },
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
