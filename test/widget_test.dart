import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportfolio_mobile/main.dart';
import 'package:myportfolio_mobile/menu.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportfolio_mobile/screens/experience_form.dart';
import 'package:myportfolio_mobile/screens/award_form.dart';
import 'package:myportfolio_mobile/screens/login_screen.dart';
import 'package:myportfolio_mobile/services/api_client.dart';

Finder field(String name) => find.byKey(ValueKey('award-$name'));

Future<void> openApp(
  WidgetTester tester, {
  void Function(Map<String, dynamic>)? onAward,
  Future<http.Response> Function(http.Request)? handleRequest,
}) async {
  final api = ApiClient(
    client: MockClient((request) async {
      if (request.url.path == '/api/v1/auth/token/') {
        return http.Response('{"token":"test-token"}', 200);
      }
      if (request.url.path == '/api/v1/awards/' && request.method == 'POST') {
        expect(request.headers['Authorization'], 'Token test-token');
        final data = jsonDecode(request.body) as Map<String, dynamic>;
        onAward?.call(data);
        return http.Response(jsonEncode({...data, 'id': 'saved-award'}), 201);
      }
      if (handleRequest != null) return handleRequest(request);
      throw StateError('Unexpected request: ${request.method} ${request.url}');
    }),
  );
  addTearDown(api.close);
  await tester.pumpWidget(MyApp(apiClient: api));
}

Future<void> login(WidgetTester tester) async {
  expect(find.byType(LoginScreen), findsOneWidget);
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'owner');
  await tester.enterText(fields.at(1), 'test-password');
  await tester.tap(find.widgetWithText(FilledButton, 'Login'));
  await tester.pumpAndSettle();
}

Future<void> openAward(
  WidgetTester tester, {
  void Function(Map<String, dynamic>)? onAward,
}) async {
  await openApp(tester, onAward: onAward);
  await tester.ensureVisible(find.text('Tambah Award'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Tambah Award'));
  await tester.pumpAndSettle();
  await login(tester);
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
  await tester.tap(find.byTooltip('Previous month'));
  await tester.pumpAndSettle();
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
  testWidgets('both public lists show details without a token', (tester) async {
    await openApp(
      tester,
      handleRequest: (request) async {
        expect(request.method, 'GET');
        expect(request.headers.containsKey('Authorization'), isFalse);
        final entries = switch (request.url.path) {
          '/api/v1/experience/' => [
            {
              'id': 'experience-uuid',
              'title': 'Flutter Internship',
              'description': 'Built the portfolio app',
              'category': 'internship',
              'category_display': 'Internship',
              'started_at': '2026-01-15T05:00:00Z',
              'ended_at': null,
            },
          ],
          '/api/v1/awards/' => [
            {
              'id': 'award-uuid',
              'title': 'Innovation Prize',
              'description': 'Student innovation competition',
              'recognition': 'First place',
              'awarded_at': '2026-01-15',
            },
          ],
          _ => throw StateError('Unexpected list URL: ${request.url}'),
        };
        return http.Response(jsonEncode(entries), 200);
      },
    );

    final titles = {
      'Lihat Experience': 'Flutter Internship',
      'Lihat Award': 'Innovation Prize',
    };
    for (final entry in titles.entries) {
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.value));
      await tester.pumpAndSettle();
      expect(find.text('Detail'), findsOneWidget);
      expect(find.text(entry.value), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }
  });

  testWidgets(
    'Experience posts the selected category and supports no end date',
    (tester) async {
      Map<String, dynamic>? submitted;
      await openApp(
        tester,
        handleRequest: (request) async {
          expect(request.url.path, '/api/v1/experience/');
          expect(request.method, 'POST');
          expect(request.headers['Authorization'], 'Token test-token');
          final data = jsonDecode(request.body) as Map<String, dynamic>;
          submitted = data;
          return http.Response(jsonEncode({...data, 'id': 'saved'}), 201);
        },
      );
      await tester.tap(find.text('Tambah Experience'));
      await tester.pumpAndSettle();
      await login(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Judul Experience'),
        '  Magang Flutter  ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Deskripsi'),
        'Mengembangkan aplikasi.',
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Internship').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextFormField, 'Tanggal Mulai'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await save(tester);

      final now = DateTime.now();
      expect(submitted, {
        'title': 'Magang Flutter',
        'description': 'Mengembangkan aplikasi.',
        'category': 'internship',
        'started_at': DateTime(
          now.year,
          now.month - 1,
          15,
        ).toUtc().toIso8601String(),
        'ended_at': null,
      });
      expect(find.text('Experience berhasil ditambahkan'), findsOneWidget);
    },
  );

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

  testWidgets('drawer keeps Home and guards the Award form', (tester) async {
    await openApp(tester);
    final home = tester.element(find.byType(MyHomePage));
    await openDrawer(tester);
    expect(find.text('Home'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Tambah Experience'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Tambah Award'));
    await tester.pumpAndSettle();
    await login(tester);
    expect(find.byType(AwardFormPage), findsOneWidget);
    await openDrawer(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(MyHomePage)), same(home));
    expect(Navigator.of(home).canPop(), isFalse);
    expect(find.byType(AwardFormPage), findsNothing);
  });

  testWidgets('drawer switches Experience to Award without stacking forms', (
    tester,
  ) async {
    await openApp(tester);
    await openDrawer(tester);
    await tester.tap(find.widgetWithText(ListTile, 'Tambah Experience'));
    await tester.pumpAndSettle();
    await login(tester);
    expect(find.byType(ExperienceFormPage), findsOneWidget);
    await openDrawer(tester);
    await tester.tap(find.widgetWithText(ListTile, 'Tambah Award'));
    await tester.pumpAndSettle();
    expect(find.byType(AwardFormPage), findsOneWidget);
    expect(find.byType(ExperienceFormPage, skipOffstage: false), findsNothing);
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

  testWidgets('valid Award sends trimmed fields and ISO date to Django', (
    tester,
  ) async {
    Map<String, dynamic>? submitted;
    await openAward(tester, onAward: (data) => submitted = data);
    await fillRequired(tester);
    await enter(tester, 'image', '  https://example.com/award.png  ');
    await save(tester);

    final now = DateTime.now();
    final date = DateTime(now.year, now.month - 1, 15);
    expect(submitted, {
      'title': 'Lomba Inovasi',
      'recognition': 'Juara 1',
      'description': 'Penghargaan proyek Flutter.',
      'image': 'https://example.com/award.png',
      'awarded_at': date.toIso8601String().split('T').first,
    });
    expect(find.text('Award berhasil ditambahkan'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('image is optional and is sent as an empty string', (
    tester,
  ) async {
    Map<String, dynamic>? submitted;
    await openAward(tester, onAward: (data) => submitted = data);
    await fillRequired(tester);
    await enter(tester, 'image', '   ');
    await save(tester);
    expect(submitted?['image'], '');
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
