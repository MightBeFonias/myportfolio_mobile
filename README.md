# myportfolio_mobile

MyPortfolio Mobile adalah prototipe aplikasi portofolio berbasis Flutter untuk Tugas 7 Pemrograman Berbasis Platform (PBP). Aplikasi ini menampilkan identitas mahasiswa dan mendemonstrasikan penggunaan widget Material 3, tata letak kisi, dan respons terhadap ketukan.

## Fitur

- Halaman utama menampilkan tiga kartu informasi berisi NPM, nama, dan kelas.
- Menu **Lihat Proyek**, **Tambah Proyek**, dan **Logout** disusun dalam tiga kolom. Ketiganya memakai ikon dan warna berbeda, masing-masing biru, hijau, dan merah.
- Ketukan pada setiap menu menampilkan `SnackBar` yang menyebut nama menu tersebut. Pada versi Tugas 7, ketiga tombol berfungsi sebagai demonstrasi interaksi.

## Menjalankan proyek

Siapkan Git, Flutter SDK yang menyertakan Dart `>=3.13.7 <4.0.0` sesuai [pubspec.yaml](pubspec.yaml), dan target yang sudah dikonfigurasi, misalnya emulator Android atau Chrome. [Panduan instalasi Flutter](https://docs.flutter.dev/install)

```bash
git clone https://github.com/MightBeFonias/myportfolio_mobile.git
cd myportfolio_mobile
flutter pub get
flutter devices
flutter run
```

Jika beberapa perangkat tersedia, pilih salah satunya dengan `flutter run -d <device-id>`. Untuk Chrome, gunakan `flutter run -d chrome`. Setelah halaman utama tampil, tekan setiap kartu menu dan periksa pesan yang muncul di bagian bawah layar. [Referensi perintah Flutter](https://docs.flutter.dev/reference/flutter-cli)

## Struktur proyek

| Berkas | Isi |
| --- | --- |
| [`lib/main.dart`](lib/main.dart) | Titik masuk aplikasi, widget `MyApp`, tema Material 3, dan penentuan halaman awal. |
| [`lib/menu.dart`](lib/menu.dart) | Halaman utama, komponen kartu informasi dan menu, serta model data menu. |
| [`pubspec.yaml`](pubspec.yaml) | Persyaratan versi Dart dan dependensi proyek. |

## Kontribusi

Gunakan [GitHub Issues](https://github.com/MightBeFonias/myportfolio_mobile/issues) untuk melaporkan masalah. Sertakan langkah reproduksi dan perangkat yang digunakan. Untuk mengusulkan perubahan kode, buat *fork*, kerjakan perubahan di cabang terpisah, jalankan `flutter analyze`, lalu ajukan *pull request*.

## Lisensi

Lisensi distribusi belum dicantumkan di repositori ini.

## Tugas 7 — Elemen Dasar Flutter

### 1. Apa itu *widget tree* dan bagaimana hubungan induk-anak bekerja?

*Widget tree* adalah susunan widget secara hierarkis yang mendeskripsikan antarmuka aplikasi. Widget induk (*parent*) dapat menerima satu anak melalui `child`, beberapa anak melalui `children`, atau anak dengan peran tertentu seperti `appBar` dan `body` pada `Scaffold`. Saat mengatur tata letak, induk meneruskan batas ukuran ke anak, anak menentukan ukurannya dalam batas tersebut, lalu induk menempatkan anak.

Di proyek ini, `runApp()` memasang `MyApp` sebagai widget akar. `MyApp` membangun `MaterialApp`, yang menetapkan `MyHomePage` sebagai halaman awal. Pada halaman itu, `Row` menjadi induk tiga `InfoCard` dan menyusunnya secara horizontal. Di cabang lain, `GridView.count` menyusun tiga `ItemCard` sebagai anak dalam kisi.

### 2. Sebutkan semua widget yang digunakan dalam proyek ini dan jelaskan fungsinya.

Widget berikut dibuat secara eksplisit di lib/main.dart dan lib/menu.dart.

| Widget | Fungsi dalam proyek |
| --- | --- |
| `MyApp` | Widget akar yang membangun `MaterialApp` dengan tema dan halaman awal proyek. |
| `MyHomePage` | Menyusun halaman utama yang berisi identitas mahasiswa, pesan sambutan, dan menu. |
| `InfoCard` | Komponen yang dipakai ulang untuk menampilkan judul dan nilai informasi NPM, nama, atau kelas. |
| `ItemCard` | Komponen yang dipakai ulang untuk menampilkan ikon dan label menu serta menangani ketukan. |
| `MaterialApp` | Menyediakan konfigurasi aplikasi Material, termasuk tema dan halaman awal. |
| `Scaffold` | Menyediakan struktur halaman untuk `AppBar`, isi halaman, dan penempatan `SnackBar`. |
| `AppBar` | Menampilkan bilah atas dengan judul **MyPortfolio** dan warna utama dari tema. |
| `Text` | Menampilkan judul, identitas, pesan sambutan, label menu, dan pesan `SnackBar`. |
| `Padding` | Memberi ruang di tepi halaman, di atas pesan sambutan, dan di antara ikon serta label menu. |
| `Column` | Menyusun bagian halaman dan isi setiap kartu secara vertikal. |
| `Row` | Menyusun ketiga kartu informasi secara horizontal dengan jarak merata. |
| `SizedBox` | Memberi jarak vertikal antara baris identitas dan bagian sambutan, serta antara judul dan isi kartu informasi. |
| `Center` | Memusatkan bagian sambutan dan menu serta isi kartu menu. |
| `GridView` | Menata kartu menu dalam kisi tiga kolom melalui konstruktor `GridView.count`. |
| `Card` | Membungkus informasi identitas dalam kartu Material dengan elevasi `2.0`. |
| `Container` | Mengatur lebar dan ruang dalam kartu informasi serta ruang dalam kartu menu. |
| `Material` | Memberi kartu menu warna dan sudut membulat serta menyediakan permukaan untuk efek riak. |
| `InkWell` | Menangani ketukan pada kartu menu, memberi efek riak, dan memicu tampilan `SnackBar`. |
| `Icon` | Menampilkan ikon folder, tambah, dan keluar pada kartu menu. |
| `SnackBar` | Menampilkan pesan sementara yang menyebut menu yang ditekan. |

`ItemHomepage` adalah kelas data untuk nama, ikon, dan warna setiap menu. Kode juga mengakses `Theme`, `MediaQuery`, dan `ScaffoldMessenger` yang tersedia pada pohon widget untuk membaca tema, memperoleh ukuran layar, dan mengelola pesan.

### 3. Apa fungsi `MaterialApp` dan mengapa widget ini umumnya digunakan sebagai widget akar?

`MaterialApp` menyediakan konfigurasi tingkat aplikasi untuk Material Design. Widget ini mengatur tema, lokalisasi, dan navigasi. Penempatan di dekat akar memberi halaman dan komponen di bawahnya akses ke konfigurasi yang sama. Saat `home` diisi, `MaterialApp` menggunakan widget tersebut untuk rute awal `/`.

Di proyek ini, `runApp()` memasang `MyApp` sebagai widget akar. `MyApp.build()` mengembalikan `MaterialApp` yang mengaktifkan Material 3, menggunakan indigo sebagai warna dasar tema, dan menetapkan `MyHomePage` sebagai `home`. `AppBar` mengambil warna utamanya dari tema tersebut.

### 4. Apa perbedaan `StatelessWidget` dan `StatefulWidget`? Kapan masing-masing digunakan?

- **`StatelessWidget`** cocok ketika tampilan dapat dibangun dari konfigurasi yang diterima dan data yang tersedia melalui `BuildContext`. `build()` dapat dipanggil ulang jika induk memberi konfigurasi baru atau jika data yang dibaca dari konteks berubah. Di proyek ini, `InfoCard` memakai `title`, `content`, dan lebar layar untuk membangun kartu informasi.
- **`StatefulWidget`** cocok ketika komponen perlu menyimpan keadaan lokal yang bisa berubah selama digunakan. Konfigurasi widget tetap *immutable*, sementara keadaan yang berubah disimpan di objek `State` terpisah. `setState()` memberi tahu Flutter untuk menjadwalkan pembangunan ulang bagian antarmuka itu. Sebagai contoh, formulir tambah proyek dapat menyimpan kategori yang dipilih atau status validasi selama pengguna mengisi formulir.

Keempat widget kustom di proyek ini menggunakan `StatelessWidget`. Saat kartu menu diketuk, `ItemCard` menyerahkan penampilan pesan kepada `ScaffoldMessenger`, sehingga kartu cukup memakai data `item` yang diterimanya.

### 5. Apa itu `BuildContext` dan bagaimana penggunaannya di `build()`?

`BuildContext` menunjukkan posisi widget di pohon. Flutter memberikan konteks kepada `build(BuildContext context)` agar widget dapat mengambil data atau mencari layanan yang tersedia melalui leluhurnya. Konteks dari metode `build()` berada di atas widget yang dikembalikan oleh metode tersebut. Jika `build()` membuat `Theme` baru, gunakan konteks widget anak atau `Builder` di bawah `Theme` itu untuk membaca tema tersebut.

Di halaman utama, `BuildContext` dipakai untuk tiga hal.

- `Theme.of(context).colorScheme.primary` mengambil warna latar `AppBar` dari tema.
- `MediaQuery.of(context).size.width / 3.5` menentukan lebar `InfoCard` dari lebar area tampilan.
- `ScaffoldMessenger.of(context)` dipanggil di dalam `onTap` untuk menyembunyikan `SnackBar` aktif dan menampilkan pesan menu yang baru ditekan.

### 6. Apa perbedaan *hot reload*, *hot restart*, dan *full restart*?

| Cara | Yang terjadi | Kapan digunakan |
| --- | --- | --- |
| **Hot reload** | Flutter memuat perubahan kode Dart dan membangun ulang pohon widget sambil mempertahankan keadaan aplikasi di memori. `main()` dan `initState()` yang sudah berjalan tidak dipanggil ulang. | Saat mengubah kode yang dijalankan oleh `build()`, misalnya mengganti teks sambutan, warna tema, atau jarak antarwidget. |
| **Hot restart** | Eksekusi Dart dimulai kembali dari `main()` dan keadaan aplikasi di memori dibuat ulang. | Saat mengubah logika di `main()` atau `initState()`, mengubah nilai awal variabel global yang sudah diinisialisasi, atau membuat perubahan yang ditolak oleh *hot reload*, seperti mengubah `enum` menjadi kelas biasa. |
| **Full restart** | Sesi aplikasi dihentikan dan dijalankan kembali sehingga kode platform yang berubah ikut dibangun dan dimuat. | Saat mengubah kode native, seperti Kotlin atau Java di Android maupun Swift atau Objective-C di iOS. |

Dalam mode debug lewat `flutter run`, tekan `r` untuk *hot reload* atau `R` untuk *hot restart*. Untuk *full restart*, hentikan sesi dan jalankan kembali `flutter run`.

### AI Disclosure

Saya menggunakan codex untuk membantu saya mengerjakan Tugas Individu 7 PBP.

Saya menggunakannya untuk beberapa hal berikut:
- Memperbaiki README.md supaya dokumentasi codenya lebih jelas dan lengkap
- Membantu saya menjawab pertanyaan reflektif yang diberikan pada Tugas 7

Untuk strategi prompting, saya melarang codex untuk melakukan commit sehingga saya bisa cek dulu perubahan-perubahan yang dilakukan codex.
