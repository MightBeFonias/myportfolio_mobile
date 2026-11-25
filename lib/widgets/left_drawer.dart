import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/screens/experience_form.dart';
import 'package:myportfolio_mobile/screens/award_form.dart';
import 'package:myportfolio_mobile/screens/portfolio_list_screen.dart';
import 'package:myportfolio_mobile/services/auth_state.dart';
import 'package:myportfolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  void _openPage(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);
    final isHome = ModalRoute.of(context)!.isFirst;
    navigator.pop(); // Tutup drawer sebelum membuka halaman.
    final route = MaterialPageRoute<void>(builder: (context) => page);
    if (isHome) {
      navigator.push(route);
    } else {
      // Ganti halaman aktif; Home tetap menjadi rute pertama.
      navigator.pushReplacement(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(16),
            child: const SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Portfolio',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Jelajahi pengalaman dan penghargaan.',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              navigator.popUntil((route) => route.isFirst);
            },
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Lihat Experience'),
            onTap: () => _openPage(context, const ExperienceListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: const Text('Lihat Award'),
            onTap: () => _openPage(context, const AwardListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Tambah Experience'),
            onTap: () async {
              if (await ensureLoggedIn(context) && context.mounted) {
                _openPage(context, const ExperienceFormPage());
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: const Text('Tambah Award'),
            onTap: () async {
              if (await ensureLoggedIn(context) && context.mounted) {
                _openPage(context, const AwardFormPage());
              }
            },
          ),
          ListTile(
            leading: Icon(isLoggedIn ? Icons.logout : Icons.login),
            title: Text(isLoggedIn ? 'Logout' : 'Login'),
            onTap: () async {
              if (isLoggedIn) {
                final request = signOut(context);
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.popUntil((route) => route.isFirst);
                await request;
              } else if (await ensureLoggedIn(context) && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
