# myportfolio_mobile

MyPortfolio Mobile adalah prototipe aplikasi portofolio berbasis Flutter untuk Pemrograman Berbasis Platform (PBP). Proyek ini menggunakan navigasi drawer dari Tutorial 09 dan formulir Award untuk Tugas 8.

## Fitur

- Halaman utama menampilkan tiga kartu informasi berisi NPM, nama, dan kelas.
- Menu **Lihat Proyek**, **Tambah Proyek**, **Tambah Award**, dan **Logout** memakai ikon dan warna berbeda. Kisi memakai dua kolom pada layar sempit dan tiga kolom pada layar lebih lebar. Halaman utama dapat digulir.
- **Tambah Proyek** membuka formulir Tutorial 09, sedangkan **Tambah Award** membuka formulir baru. **Lihat Proyek** dan **Logout** masih menampilkan `SnackBar` demonstrasi.
- Drawer bersama menyediakan **Home**, **Add Project**, dan **Add Award**. **Home** kembali ke halaman utama yang sudah ada.
- Formulir Award memvalidasi judul, recognition, deskripsi, URL gambar opsional, dan tanggal penghargaan sebelum menampilkan dialog ringkasan. Tombol **Tutup** mengembalikan pengguna ke formulir dengan isian tetap tersedia.
- Tombol **Simpan** pada tugas ini hanya menampilkan ringkasan; belum menyimpan data ke basis data atau mengirimkannya ke backend.

## Menjalankan proyek

Siapkan Git, Flutter SDK yang menyertakan Dart `>=3.13.7 <4.0.0` sesuai [pubspec.yaml](pubspec.yaml), dan target yang sudah dikonfigurasi, misalnya emulator Android atau Chrome. [Panduan instalasi Flutter](https://docs.flutter.dev/install)

```bash
git clone https://github.com/MightBeFonias/myportfolio_mobile.git
cd myportfolio_mobile
flutter pub get
flutter devices
flutter run
```

Jika beberapa perangkat tersedia, pilih salah satunya dengan `flutter run -d <device-id>`. Untuk Chrome, gunakan `flutter run -d chrome`. Setelah halaman utama tampil, tekan **Tambah Award**, isi formulir, lalu tekan **Simpan**. Gunakan **Home** pada drawer formulir untuk kembali saat menjalankan aplikasi di Chrome. [Referensi perintah Flutter](https://docs.flutter.dev/reference/flutter-cli)

## Struktur proyek

| Berkas | Isi |
| --- | --- |
| [`lib/main.dart`](lib/main.dart) | Titik masuk aplikasi, widget `MyApp`, tema Material 3, dan penentuan halaman awal. |
| [`lib/menu.dart`](lib/menu.dart) | Halaman utama, komponen kartu informasi dan menu, serta model data menu. |
| [`lib/project_form.dart`](lib/project_form.dart) | Formulir Add Project dari Tutorial 09. |
| [`lib/screens/award_form.dart`](lib/screens/award_form.dart) | Formulir Award, pemilih tanggal, validasi, dan dialog ringkasan. |
| [`lib/widgets/left_drawer.dart`](lib/widgets/left_drawer.dart) | Drawer bersama untuk Home, Add Project, dan Add Award. |
| [`test/widget_test.dart`](test/widget_test.dart) | Pengujian navigasi, validasi, dialog, dan layar sempit dengan papan ketik. |
| [`pubspec.yaml`](pubspec.yaml) | Persyaratan versi Dart dan dependensi proyek. |

### Tugas 8

1. **Perbedaan `Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`, serta navigasi formulir dan Home**

   `Navigator.push()` menambahkan rute baru di atas tumpukan navigasi. Rute sebelumnya tetap tersedia, sehingga pengguna dapat kembali dengan tombol kembali perangkat. Kartu **Tambah Award** di `lib/menu.dart` menggunakan `Navigator.push()` dengan `MaterialPageRoute` menuju `AwardFormPage`.

   `Navigator.pushReplacement()` mengganti rute yang sedang aktif. Dalam drawer, metode ini digunakan ketika berpindah dari satu formulir ke formulir lain, misalnya Add Project ke Add Award. Dengan demikian, pergantian formulir tidak terus menumpuk rute. Saat formulir dibuka dari Home melalui drawer, aplikasi menggunakan `push()` agar Home tetap menjadi rute pertama.

   `Navigator.pop()` menutup rute teratas atau entri riwayat lokal seperti drawer. Opsi **Home** terlebih dahulu menutup drawer dengan `pop()`, kemudian menjalankan `popUntil((route) => route.isFirst)` untuk kembali ke halaman utama yang sudah ada, tanpa membuat salinan Home. Alur ini juga dapat dipakai di Chrome. Tombol **Tutup** pada dialog menggunakan `pop()` dengan konteks dialog agar hanya dialog yang ditutup.

2. **Konsistensi struktur `Scaffold`, `AppBar`, `Drawer`, dan tema**

   Setiap halaman memakai `Scaffold` untuk menyediakan tempat bagi bilah judul, drawer, dan isi halaman. `AppBar` menjelaskan halaman yang sedang dibuka, sedangkan komponen `LeftDrawer` yang sama menyediakan pilihan navigasi konsisten di Home, Add Project, dan Add Award.

   `MyApp` menetapkan `ColorScheme.fromSeed(seedColor: Colors.indigo)` dan `AppBarTheme` di `lib/main.dart`. AppBar Home dan Award sama-sama mengambil warna `colorScheme.primary` serta teks putih dari tema tersebut. Latar header drawer juga memakai `Theme.of(context).colorScheme.primary`, sehingga warna identitas portofolio konsisten di beberapa halaman.

3. **Alasan pemilihan tata letak formulir dan peran jarak serta pengguliran**

   Formulir memakai `Column` dengan satu kolom agar urutan pengisian judul, recognition, deskripsi, URL gambar, tanggal, lalu Simpan mudah diikuti. `ConstrainedBox(maxWidth: 640)` menjaga kolom tetap nyaman dibaca pada layar lebar. `Padding` memberi jarak dari tepi layar, dan `SizedBox` memisahkan input serta tombol agar tidak berhimpitan. `SafeArea` menghindarkan isi dari area sistem perangkat.

   `SingleChildScrollView` membungkus seluruh formulir agar input dan tombol Simpan tetap dapat dijangkau pada layar sempit. Ketika papan ketik tampil, `Scaffold` secara default memperkecil area isi, lalu pengguna dapat menggulir ruang yang tersisa. Deskripsi menggunakan input beberapa baris. Isi dialog ringkasan juga dapat digulir sehingga deskripsi panjang tidak membuat tombol Tutup tidak terjangkau.

4. **Peran `GlobalKey<FormState>`, `validator`, dan `validate()` saat Simpan ditekan**

   `_formKey` menghubungkan kode tombol Simpan dengan `FormState` dari formulir Award. Setiap `validator` mengembalikan pesan kesalahan jika nilai tidak sah dan `null` jika sah. Saat Simpan ditekan, `_formKey.currentState!.validate()` menjalankan semua validator dan menampilkan pesan pada kolom terkait. Jika hasilnya `false`, proses berhenti. Jika seluruh input valid, `FormState.save()` menjalankan `onSaved` untuk mengambil teks yang sudah di-`trim()`, lalu `showDialog()` menampilkan semua isian dalam `AlertDialog`.

   Sebagai contoh, judul berisi `"   "` ditolak karena setelah `trim()` tidak ada karakter bermakna. Judul atau recognition lebih dari 255 karakter juga ditolak. URL gambar boleh kosong, tetapi jika diisi harus berupa URL lengkap dengan host yang valid, tanpa spasi, dan maksimal 200 karakter. Pemilih tanggal menggunakan `showDatePicker()` dan tanggal wajib dipilih. Tidak ada pemeriksaan urutan tanggal karena model Award hanya memiliki satu atribut tanggal.

   `TextInputType.url` hanya membantu menyediakan papan ketik yang sesuai; pengguna masih dapat mengetik atau menempelkan `bukan-url`. Karena itu, jenis input dan papan ketik belum cukup untuk memastikan data valid. Pemeriksaan tetap dilakukan melalui validator sebelum dialog dibuka.

#### AI Disclosure — Tugas 8

Saya menggunakan Codex untuk membantu memeriksa checklist tugas, menerapkan formulir Award berdasarkan model backend, menambahkan kartu serta navigasi drawer, memperbaiki tata letak layar sempit, menulis pengujian, dan menyusun jawaban reflektif README ini. Saya menentukan section Award dan memberikan empat pertanyaan reflektif beserta format README yang diwajibkan.

Prompt yang saya gunakan mencakup permintaan untuk memeriksa implementasi `myportfolio_mobile` terhadap checklist, lalu meminta implementasi seluruh kekurangannya dengan section Award. Proses bantuan mencakup membaca source dan model yang ada, menerapkan perubahan, menjalankan analisis serta pengujian, dan memperbaiki masalah yang ditemukan. Jawaban dan implementasi yang dihasilkan AI perlu saya pahami sebagai bagian dari pembelajaran tugas ini.
