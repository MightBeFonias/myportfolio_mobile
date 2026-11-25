import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/screens/login_screen.dart';
import 'package:myportfolio_mobile/services/api_client.dart';
import 'package:myportfolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) return true;
  final loggedIn = await Navigator.of(context)
      .push<bool>(MaterialPageRoute(builder: (_) => const LoginScreen()));
  return loggedIn ?? false;
}

Future<void> signOut(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  var message = 'Berhasil logout.';
  try {
    await context.read<AuthState>().logout();
  } on ApiException catch (error) {
    if (error.statusCode != 401) {
      message = 'Logout dari aplikasi berhasil. Token gagal dicabut di Django.';
    }
  } catch (_) {
    message = 'Logout dari aplikasi berhasil. Token gagal dicabut di Django.';
  }
  if (messenger.mounted) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
