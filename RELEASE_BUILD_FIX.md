# Release Build Button Fix

## Problem
Tombol SMP, SMA, dan E-Book di `lib/presentation/main_menu/main_menu.screen.dart` tidak bisa diklik saat build APK release.

## Root Cause
Masalah ini disebabkan oleh **R8/ProGuard code shrinking** yang aktif secara default di build release. R8 menghapus kode yang dianggap tidak terpakai, termasuk:
- Method `checkTokenBeforeRouting` dari `SecureStorageHelper`
- Class `CustomButton` widget
- Class dan method yang diakses via reflection oleh Flutter framework

## Solution
Berikut adalah perbaikan yang telah dilakukan:

### 1. Tambah ProGuard Configuration
File: `android/app/proguard-rules.pro`
- Menambahkan rules untuk menjaga class-class penting agar tidak dihapus oleh R8
- Rules khusus untuk Flutter, GetX, Secure Storage, dan custom components

### 2. Enable ProGuard di Build Configuration
File: `android/app/build.gradle.kts`
- Mengaktifkan `isMinifyEnabled = true` dan `isShrinkResources = true`
- Menggunakan file `proguard-rules.pro`

### 3. Tambah @Keep Annotation
Menambahkan annotation `@Keep` pada:
- `SecureStorageHelper` class dan `checkTokenBeforeRouting` method
- `CustomButton` class

Annotation ini memberitahu R8 untuk tidak menghapus class/method tersebut.

## Files Modified
1. `android/app/proguard-rules.pro` (new file)
2. `android/app/build.gradle.kts` (updated)
3. `lib/core/utils/secure_storage.dart` (added @Keep annotations)
4. `lib/presentation/@shared/widgets/buttons/custom_button.dart` (added @Keep annotation)

## Testing
Setelah menerapkan perbaikan ini:
1. Clean project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Build release APK: `flutter build apk --release`

Tombol SMP, SMA, dan E-Book seharusnya sudah bisa diklik di build release.

## Additional Notes
- Pastikan untuk testing di release build setiap kali ada perubahan pada class yang digunakan di button handlers
- Jika masalah masih ada, tambahkan class/method lain ke ProGuard rules
- Monitor logs untuk error terkait missing class/method di release build
