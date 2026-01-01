class Validators {
  static String? requiredField(String? value, {String fieldName = "Field"}) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName tidak boleh kosong";
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email tidak boleh kosong";
    }
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(value.trim())) {
      return "Format email tidak valid";
    }
    return null;
  }

  static String? minLength(String? value, int length,
      {String fieldName = "Field"}) {
    if (value == null || value.length < length) {
      return "$fieldName minimal $length karakter";
    }
    return null;
  }

  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password tidak boleh kosong";
    }

    final hasUppercase = RegExp(r'[A-Z]');
    final hasDigits = RegExp(r'[0-9]');
    final hasLowercase = RegExp(r'[a-z]');
    final hasSpecialCharacters = RegExp(r'[!@#\$&*~]');

    if (!hasUppercase.hasMatch(value)) {
      return "Password harus mengandung huruf besar";
    }
    if (!hasLowercase.hasMatch(value)) {
      return "Password harus mengandung huruf kecil";
    }
    if (!hasDigits.hasMatch(value)) {
      return "Password harus mengandung angka";
    }
    if (!hasSpecialCharacters.hasMatch(value)) {
      return "Password harus mengandung karakter spesial (!@#\$&*~)";
    }
    if (value.length < 8) {
      return "Password minimal 8 karakter";
    }

    return null;
  }

  static String? match(String? value1, String? value2, {String? errorMessage}) {
    if (value1 != value2) {
      return errorMessage ?? "Field tidak cocok";
    }
    return null;
  }
}
