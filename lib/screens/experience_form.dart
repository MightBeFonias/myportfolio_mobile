import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/models/experience.dart';
import 'package:myportfolio_mobile/widgets/left_drawer.dart';
import 'package:myportfolio_mobile/widgets/portfolio_submission.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();
  String? _category;
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _startDate.dispose();
    _endDate.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: (start ? _startedAt : _endedAt) ?? now,
      firstDate: DateTime(1900),
      lastDate: start ? now : DateTime(9999, 12, 31),
    );
    if (!mounted || date == null) return;
    final formatted = MaterialLocalizations.of(context).formatMediumDate(date);
    setState(() {
      if (start) {
        _startedAt = date;
        _startDate.text = formatted;
      } else {
        _endedAt = date;
        _endDate.text = formatted;
      }
    });
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final experience = Experience(
      title: _title.text.trim(),
      description: _description.text.trim(),
      category: _category!,
      startedAt: _startedAt!.toUtc(),
      endedAt: _endedAt?.toUtc(),
    );
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await submitPortfolioEntry(
        context,
        save: (api, token) => api.createExperience(experience, token: token),
        successMessage: 'Experience berhasil ditambahkan',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) =>
      value!.trim().isEmpty ? 'Kolom ini wajib diisi.' : null;

  InputDecoration _decoration(String label, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: suffix,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Experience')),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _title,
                decoration: _decoration('Judul Experience'),
                enabled: !_saving,
                maxLength: 255,
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                decoration: _decoration('Deskripsi'),
                enabled: !_saving,
                minLines: 3,
                maxLines: 6,
                validator: _required,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: _decoration('Kategori'),
                items: [
                  for (final category in experienceCategories.entries)
                    DropdownMenuItem(
                      value: category.key,
                      child: Text(category.value),
                    ),
                ],
                onChanged: _saving ? null : (value) => _category = value,
                validator: (value) => value == null ? 'Pilih kategori.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startDate,
                decoration: _decoration(
                  'Tanggal Mulai',
                  suffix: const Icon(Icons.calendar_month),
                ),
                readOnly: true,
                enabled: !_saving,
                onTap: () => _pickDate(start: true),
                validator: (_) =>
                    _startedAt == null ? 'Pilih tanggal mulai.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _endDate,
                decoration: _decoration(
                  'Tanggal Selesai (opsional)',
                  suffix: _endedAt == null
                      ? const Icon(Icons.calendar_month)
                      : IconButton(
                          tooltip: 'Hapus tanggal selesai',
                          onPressed: _saving
                              ? null
                              : () => setState(() {
                                  _endedAt = null;
                                  _endDate.clear();
                                }),
                          icon: const Icon(Icons.clear),
                        ),
                ),
                readOnly: true,
                enabled: !_saving,
                onTap: () => _pickDate(start: false),
                validator: (_) {
                  final start = _startedAt;
                  if (start != null && (_endedAt?.isBefore(start) ?? false)) {
                    return 'Tanggal selesai harus sama atau setelah tanggal mulai.';
                  }
                  return null;
                },
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
    );
  }
}
