import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportfolio_mobile/main.dart';
import 'package:myportfolio_mobile/menu.dart';
import 'package:myportfolio_mobile/project_form.dart';
import 'package:myportfolio_mobile/screens/award_form.dart';

Finder field(String name) => find.byKey(ValueKey('award-$name'));

Future<void> openAward(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Tambah Award'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tambah Award'));
  await tester.pumpAndSettle();
}

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

Future<void> enter(WidgetTester tester, String name, String value) async {
  await tester.ensureVisible(field(name));
  await tester.pumpAndSettle();
  await tester.enterText(field(name), value);
}

Future<void> pickDate(WidgetTester tester) async {
  await tester.ensureVisible(field('date'));
  await tester.pumpAndSettle();
  await tester.tap(field('date'));
  await tester.pumpAndSettle();
  expect(find.byType(DatePickerDialog), findsOneWidget);
  await tester.tap(find.text('15'));
  await tester.tap(find.text('Pilih'));
  await tester.pumpAndSettle();
}

Future<void> fillRequired(WidgetTester tester) async {
  await enter(tester, 'title', '  Lomba Inovasi  ');
  await enter(tester, 'recognition', '  Juara 1  ');
  await enter(tester, 'description', '  Penghargaan proyek Flutter.  ');
  await pickDate(tester);
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Simpan'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Award card opens form and system back returns to Home', (
    tester,
  ) async {
    await openAward(tester);
    expect(find.byType(AwardFormPage), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(AwardFormPage), findsNothing);
  });

  testWidgets('drawer preserves Home and Add Project and opens Add Award', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    final home = tester.element(find.byType(MyHomePage));
    await openDrawer(tester);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    await tester.tap(find.text('Add Award'));
    await tester.pumpAndSettle();
    expect(find.byType(AwardFormPage), findsOneWidget);
    await openDrawer(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(MyHomePage)), same(home));
    expect(Navigator.of(home).canPop(), isFalse);
    expect(find.byType(AwardFormPage), findsNothing);
  });

  testWidgets('drawer switches Project to Award without stacking forms', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await openDrawer(tester);
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
    await openDrawer(tester);
    await tester.tap(find.text('Add Award'));
    await tester.pumpAndSettle();
    expect(find.byType(AwardFormPage), findsOneWidget);
    expect(find.byType(ProjectFormPage, skipOffstage: false), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  for (final value in ['', '   ']) {
    testWidgets(
      'required fields reject ${value.isEmpty ? 'empty' : 'spaces'}',
      (tester) async {
        await openAward(tester);
        await enter(tester, 'title', value);
        await enter(tester, 'recognition', value);
        await enter(tester, 'description', value);
        await save(tester);
        expect(
          find.text('Judul award tidak boleh kosong atau hanya spasi.'),
          findsOneWidget,
        );
        expect(
          find.text('Recognition tidak boleh kosong atau hanya spasi.'),
          findsOneWidget,
        );
        expect(
          find.text('Deskripsi tidak boleh kosong atau hanya spasi.'),
          findsOneWidget,
        );
        expect(find.text('Tanggal penghargaan wajib dipilih.'), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
      },
    );
  }

  testWidgets('valid Award shows all trimmed values and keeps form on close', (
    tester,
  ) async {
    await openAward(tester);
    await fillRequired(tester);
    await enter(tester, 'image', '  https://example.com/award.png  ');
    await save(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Judul Award: Lomba Inovasi'), findsOneWidget);
    expect(find.text('Recognition: Juara 1'), findsOneWidget);
    expect(find.text('Deskripsi: Penghargaan proyek Flutter.'), findsOneWidget);
    expect(
      find.text('URL Gambar: https://example.com/award.png'),
      findsOneWidget,
    );
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    expect(
      find.text('Tanggal Penghargaan: 15/$month/${now.year}'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(AwardFormPage), findsOneWidget);
    expect(
      tester.widget<TextFormField>(field('date')).controller!.text,
      '15/$month/${now.year}',
    );
    await save(tester);
    expect(find.text('Judul Award: Lomba Inovasi'), findsOneWidget);
  });

  testWidgets('image is optional and reports blank value in summary', (
    tester,
  ) async {
    await openAward(tester);
    await fillRequired(tester);
    await enter(tester, 'image', '   ');
    await save(tester);
    expect(find.text('URL Gambar: Tidak diisi'), findsOneWidget);
  });

  for (final name in ['title', 'recognition']) {
    testWidgets('$name rejects more than 255 characters', (tester) async {
      await openAward(tester);
      await fillRequired(tester);
      await enter(tester, name, List.filled(256, 'A').join());
      await save(tester);
      final label = name == 'title' ? 'Judul award' : 'Recognition';
      expect(find.text('$label maksimal 255 karakter.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });
  }

  testWidgets('maximum valid lengths are accepted', (tester) async {
    await openAward(tester);
    await fillRequired(tester);
    await enter(tester, 'title', List.filled(255, 'A').join());
    await enter(tester, 'recognition', List.filled(255, 'B').join());
    final image = 'https://example.com/${List.filled(180, 'a').join()}';
    expect(image.length, 200);
    await enter(tester, 'image', image);
    await save(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  for (final url in [
    'bukan-url',
    'example.com/award.png',
    'https://',
    'https://exa mple.com/a.png',
    'javascript:alert(1)',
    'https://999.999.999.999/image.png',
    'https://-example.com/image.png',
  ]) {
    testWidgets('reject malformed image URL: $url', (tester) async {
      await openAward(tester);
      await fillRequired(tester);
      await enter(tester, 'image', url);
      await save(tester);
      expect(
        find.text(
          'Masukkan URL lengkap, misalnya https://example.com/award.png.',
        ),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });
  }

  testWidgets('image URL rejects more than 200 characters', (tester) async {
    await openAward(tester);
    await fillRequired(tester);
    await enter(
      tester,
      'image',
      'https://example.com/${List.filled(181, 'a').join()}',
    );
    await save(tester);
    expect(find.text('URL gambar maksimal 200 karakter.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('cancelling date picker leaves date required', (tester) async {
    await openAward(tester);
    await tester.ensureVisible(field('date'));
    await tester.tap(field('date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    await save(tester);
    expect(find.text('Tanggal penghargaan wajib dipilih.'), findsOneWidget);
  });

  testWidgets('small screen and keyboard can reach Award and Save', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openAward(tester);
    await enter(tester, 'title', 'Award');
    tester.view.viewInsets = FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    await save(tester);
    expect(
      find.text('Recognition tidak boleh kosong atau hanya spasi.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
