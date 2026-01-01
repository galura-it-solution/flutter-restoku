import 'dart:math';

String generateNameByDateTime() {
  // Mendapatkan DateTime saat ini
  DateTime now = DateTime.now();

  // Mengubah DateTime menjadi string dengan format yyyyMMddHHmmss
  String formattedDate =
      "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}"
      "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

  // Menggabungkan string DateTime dengan nama acak
  return formattedDate;
}

String generateRandomName(int length) {
  const chars =
      "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  Random rnd = Random();
  String randomName = String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
    ),
  );
  return randomName;
}

String getRandomKey({int length = 10, String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'}) {
  final Random randomNumberGenerator = Random();
  int randomNumber = randomNumberGenerator.nextInt(chars.length);
  String key = chars.substring(randomNumber, randomNumber + 1);
  for (var i = 1; i < length; i += 1) {
    randomNumber = randomNumberGenerator.nextInt(chars.length);
    key += chars.substring(randomNumber, randomNumber + 1);
  }
  return key;
}
