# Weather App

Aplikasi cuaca sederhana berbasis Flutter yang menampilkan:

- cuaca saat ini
- prakiraan per jam
- prakiraan harian
- pencarian kota
- refresh data
- loading state
- cache offline

Project ini disusun dengan pemisahan antara data, logika, dan tampilan supaya lebih mudah dibaca, dicek, dan dikembangkan.

## Struktur Folder

Folder utama di `lib/` dibagi berdasarkan tanggung jawab:

- `models/` untuk model data cuaca
- `services/` untuk API dan cache
- `providers/` untuk state management, terutama `WeatherProvider`
- `views/` untuk halaman utama
- `widgets/` untuk komponen UI yang reusable
- `utils/` untuk helper seperti format data dan filter

Struktur ini dipilih supaya kode lebih rapi dan saat ada perubahan atau penambahan fitur, file yang perlu diedit lebih mudah ditemukan.

## Kenapa Pakai Struktur Ini

Beberapa alasan pemilihan struktur folder:

- setiap folder punya tugas yang jelas
- kode tidak tercampur antara UI, logic, dan data
- lebih mudah maintenance
- lebih enak dikembangkan kalau nanti ada fitur baru

## State Management

Project ini memakai pendekatan **Provider-style state management** dengan `ChangeNotifier` melalui class `WeatherProvider`.

Cara kerjanya:

1. Semua data cuaca dan status aplikasi disimpan di `WeatherProvider`.
2. UI mendengarkan perubahan state dari provider.
3. Saat data berubah, `notifyListeners()` dipanggil.
4. Widget terkait akan rebuild otomatis.

Pendekatan ini cocok untuk aplikasi dengan state yang masih terpusat dan tidak terlalu kompleks.

## Kenapa Memilih Provider

Provider dipilih karena:

- sederhana dan mudah dipahami
- tidak seberat Bloc untuk kebutuhan project ini
- cocok untuk aplikasi skala kecil sampai menengah
- logika aplikasi bisa dipisahkan dari UI
- mendukung async flow dengan baik untuk kebutuhan fetch API

Untuk project weather app seperti ini, Provider sudah cukup, jelas, dan efisien.

