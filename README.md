# Restoku App (Flutter)

Aplikasi mobile Restoku untuk pelanggan dan penjual.

## Fitur Utama

- Pelanggan: lihat menu, tambah ke keranjang, buat pesanan, cek riwayat & detail pesanan.
- Penjual: kelola menu, kategori, meja, dan status pesanan dapur.
- Realtime: notifikasi pesanan selesai via SSE dengan fallback polling.

## Kebutuhan

- Flutter SDK
- Restoku API berjalan (default `http://localhost:8000`)

## Konfigurasi API Base URL

Ubah `restoku-app/lib/config.dart` agar sesuai server API:

```
url_api: "http://localhost:8000",
```

## Cara Menjalankan (Development)

```
flutter pub get
flutter run
```

## Akun Test (Local)

Jika menjalankan seeder backend:

- Seller: `seller@restoku.test` / `password`

Pelanggan dapat registrasi dari aplikasi dan verifikasi OTP.

## Build (Release)

```
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

## Paket Penting, Pengaruh ke Performa & Security

- `get`: routing dan state management cepat; sederhana tapi pastikan lifecycle controller rapi agar tidak ada kebocoran state.
- `dio` + `http`: komunikasi API; performa tergantung konfigurasi timeout/interceptor. Pastikan HTTPS di produksi.
- `flutter_secure_storage`: menyimpan token sensitif di Keychain/Keystore; aman untuk credential, tapi aksesnya lebih lambat dibanding shared prefs.
- `shared_preferences`: simpan data non-sensitif (flag, setting); cepat namun tidak aman untuk token.
- `cached_network_image`: caching gambar; meningkatkan performa dan hemat bandwidth, tetapi perlu invalidasi jika gambar sering berubah.
- `image_picker`: akses galeri/kamera; perlu izin runtime dan kebijakan privacy yang jelas.
- `mobile_scanner`: scan QR/barcode; intensif kamera, gunakan hanya saat dibutuhkan agar baterai hemat.
- `flutter_form_builder` + `form_builder_validators`: mempermudah validasi; ringan, tapi pastikan key Form tidak duplikat.
- `cached_query_flutter`: caching data network; mempercepat UI, tapi perlu strategi cache agar data tetap segar.
- `webview_flutter`: membuka konten web; isolasi konten tidak seketat native, pastikan URL terpercaya.
- `syncfusion_flutter_pdfviewer`: rendering PDF; bisa berat di device low-end, gunakan loading state.
- `flutter_launcher_icons`: hanya untuk generate ikon; tidak berdampak ke runtime.
- `logger`: logging debug; matikan/kurangi di release untuk keamanan data log.

## Catatan

- Gambar menu dan kategori menggunakan `image_url` dari API.
- Notifikasi pesanan siap mengarah ke halaman detail pesanan saat ditekan.

## Highlight Penerapan Security & Performa

Security:
- Token disimpan di `flutter_secure_storage` (Keychain/Keystore), bukan di `shared_preferences` agar aman dari pencurian token.
- Validasi input menggunakan `flutter_form_builder` agar data lebih terkontrol sebelum dikirim.
- Rekomendasi produksi: gunakan HTTPS dan batasi logging sensitif.

Performa:
- Gambar di-cache dengan `cached_network_image` untuk mempercepat loading dan hemat bandwidth.
- Data API bisa di-cache via `cached_query_flutter` agar UI responsif.
- Alasan SSE: kebutuhan update bersifat satu arah (server -> client), lebih sederhana dari WebSocket, kompatibel dengan HTTP/proxy umum, dan lebih mudah dioperasikan tanpa infrastruktur socket khusus.
