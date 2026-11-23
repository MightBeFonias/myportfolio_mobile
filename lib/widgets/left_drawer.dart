import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/project_form.dart';
import 'package:myportfolio_mobile/screens/award_form.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  void _openForm(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);
    final isHome = ModalRoute.of(context)!.isFirst;
    navigator.pop(); // Tutup drawer sebelum membuka halaman.
    final route = MaterialPageRoute<void>(builder: (context) => page);
    if (isHome) {
      navigator.push(route);
    } else {
      // Ganti formulir aktif; halaman Home tetap menjadi rute pertama.
      navigator.pushReplacement(route);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Explore personal projects and awards!',
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
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () => _openForm(context, const ProjectFormPage()),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events_outlined),
            title: const Text('Add Award'),
            onTap: () => _openForm(context, const AwardFormPage()),
          ),
        ],
      ),
    );
  }
}
