import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/models/award.dart';
import 'package:myportfolio_mobile/widgets/left_drawer.dart';
import 'package:myportfolio_mobile/widgets/portfolio_submission.dart';

class AwardFormPage extends StatefulWidget {
  const AwardFormPage({super.key});

  @override
  State<AwardFormPage> createState() => _AwardFormPageState();
}

class _AwardFormPageState extends State<AwardFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();

  String _title = '';
  String _recognition = '';
  String _description = '';
  String _image = '';
  DateTime? _awardedAt;
  bool _saving = false;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String label, {int? maxLength}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label tidak boleh kosong atau hanya spasi.';
    if (maxLength != null && text.runes.length > maxLength) {
      return '$label maksimal $maxLength karakter.';
    }
    return null;
  }

  String? _validateImageUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null; // Award.image memiliki blank=True.
    if (text.runes.length > 200) return 'URL gambar maksimal 200 karakter.';

    final uri = Uri.tryParse(text);
    if (RegExp(r'\s').hasMatch(text) ||
        uri == null ||
        !const ['http', 'https', 'ftp', 'ftps'].contains(uri.scheme) ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        !_isValidHost(uri.host)) {
      return 'Masukkan URL lengkap, misalnya https://example.com/award.png.';
    }
    return null;
  }

  bool _isValidHost(String host) {
    if (host == 'localhost') return true;
    // Uri.tryParse sudah memeriksa sintaks alamat IPv6 di dalam tanda [].
    if (host.startsWith('[') && host.endsWith(']')) return true;
    if (RegExp(r'^[0-9.]+$').hasMatch(host)) {
      final parts = host.split('.');
      return parts.length == 4 &&
          parts.every((part) {
            final number = int.tryParse(part);
            return number != null && number >= 0 && number <= 255;
          });
    }
    final labels = host.endsWith('.')
        ? host.substring(0, host.length - 1).split('.')
        : host.split('.');
    return host.length <= 253 &&
        labels.length >= 2 &&
        labels.every(
          (label) =>
              RegExp(r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$')
                  .hasMatch(label),
        );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year.toString().padLeft(4, '0')}';

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _awardedAt ?? today,
      firstDate: DateTime(1),
      lastDate: today,
      helpText: 'Pilih tanggal penghargaan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (!mounted || date == null) return;
    setState(() {
      _awardedAt = date;
      _dateController.text = _formatDate(date);
    });
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final award = Award(
      title: _title,
      recognition: _recognition,
      description: _description,
      image: _image,
      awardedAt: _awardedAt!,
    );
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await submitPortfolioEntry(
        context,
        save: (api, token) => api.createAward(award, token: token),
        successMessage: 'Award berhasil ditambahkan',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String label, {String? hint, IconData? icon}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixIcon: icon == null ? null : Icon(icon),
        errorMaxLines: 3,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Award')),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Catat penghargaan dan pencapaianmu. '
                      'Semua kolom wajib diisi kecuali URL gambar.',
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      enabled: !_saving,
                      key: const ValueKey('award-title'),
                      decoration: _decoration('Judul Award'),
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      validator: (value) => _validateRequired(
                        value,
                        'Judul award',
                        maxLength: 255,
                      ),
                      onSaved: (value) => _title = value!.trim(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      enabled: !_saving,
                      key: const ValueKey('award-recognition'),
                      decoration: _decoration(
                        'Recognition',
                        hint: 'Contoh: Juara 1 atau Medali Emas',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      validator: (value) => _validateRequired(
                        value,
                        'Recognition',
                        maxLength: 255,
                      ),
                      onSaved: (value) => _recognition = value!.trim(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      enabled: !_saving,
                      key: const ValueKey('award-description'),
                      decoration: _decoration('Deskripsi'),
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 3,
                      maxLines: 6,
                      validator: (value) =>
                          _validateRequired(value, 'Deskripsi'),
                      onSaved: (value) => _description = value!.trim(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      enabled: !_saving,
                      key: const ValueKey('award-image'),
                      decoration: _decoration(
                        'URL Gambar (opsional)',
                        hint: 'https://example.com/award.png',
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      validator: _validateImageUrl,
                      onSaved: (value) => _image = value?.trim() ?? '',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      enabled: !_saving,
                      key: const ValueKey('award-date'),
                      controller: _dateController,
                      readOnly: true,
                      decoration: _decoration(
                        'Tanggal Penghargaan',
                        hint: 'Pilih tanggal',
                        icon: Icons.calendar_month,
                      ),
                      onTap: _pickDate,
                      validator: (_) => _awardedAt == null
                          ? 'Tanggal penghargaan wajib dipilih.'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(_saving ? 'Sedang menyimpan…' : 'Simpan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
