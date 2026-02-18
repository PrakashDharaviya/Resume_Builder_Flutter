class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final phoneRegex = RegExp(r'^[0-9+\-\s()]{10,}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // URL validation
  static String? validateURL(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // General text validation with min/max length
  static String? validateText(
    String? value,
    String fieldName, {
    int? minLength,
    int? maxLength,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      if (required) {
        return '$fieldName is required';
      }
      return null;
    }

    if (minLength != null && value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (maxLength != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }

  // Date validation
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // Number validation
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }

    return null;
  }
}
