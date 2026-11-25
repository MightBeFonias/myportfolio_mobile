import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/services/api_client.dart';
import 'package:myportfolio_mobile/services/auth_state.dart';
import 'package:myportfolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

Future<void> submitPortfolioEntry(
  BuildContext context, {
  required Future<void> Function(ApiClient api, String token) save,
  required String successMessage,
}) async {
  final auth = context.read<AuthState>();
  final api = context.read<ApiClient>();
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  if (!await ensureLoggedIn(context) || !context.mounted) return;
  final token = auth.token;
  if (token == null) return;

  void showMessage(String message) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  try {
    await save(api, token);
  } on ApiException catch (error) {
    if (error.statusCode == 401) auth.expire(token);
    if (!context.mounted) return;
    if (error.statusCode == 401) {
      showMessage('Sesi berakhir. Silakan login ulang.');
      final loggedIn = await ensureLoggedIn(context);
      if (context.mounted && loggedIn) {
        showMessage('Tekan Simpan untuk mencoba lagi.');
      }
    } else {
      showMessage(switch (error.statusCode) {
        400 => 'Data ditolak. Periksa kembali kolom formulir.',
        403 => 'Hanya pemilik portofolio yang dapat menambahkan data.',
        _ => 'Data gagal disimpan (${error.statusCode}).',
      });
    }
    return;
  } catch (_) {
    if (context.mounted) {
      showMessage(
        'Penyimpanan belum terkonfirmasi. Cek daftar sebelum mencoba lagi.',
      );
    }
    return;
  }

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(successMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
  if (context.mounted && ModalRoute.of(context)?.isCurrent == true) {
    navigator.pop();
  }
}
