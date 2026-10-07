class Validators {
  // Validate Email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Validate Password (min 6 characters)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Validate Confirm Password
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Validate Name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // Validate Required Text Field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Validate Phone Number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Enter a valid phone number (at least 10 digits)';
    }
    return null;
  }

  // Validate Postal / PIN Code
  static String? validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Postal code is required';
    }
    if (value.trim().length < 4) {
      return 'Enter a valid postal code';
    }
    return null;
  }

  // Validate Card Number
  static String? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Card number is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\s+'), '');
    if (digitsOnly.length != 16 || int.tryParse(digitsOnly) == null) {
      return 'Enter a valid 16-digit card number';
    }
    return null;
  }

  // Validate Expiry Date MM/YY
  static String? validateExpiryDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expiry date required (MM/YY)';
    }
    final parts = value.split('/');
    if (parts.length != 2) {
      return 'Format must be MM/YY';
    }
    final month = int.tryParse(parts[0].trim());
    final year = int.tryParse(parts[1].trim());
    if (month == null || month < 1 || month > 12) {
      return 'Invalid month (01-12)';
    }
    if (year == null || year < 24) {
      return 'Invalid year';
    }
    return null;
  }

  // Validate CVV
  static String? validateCvv(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVV is required';
    }
    if (value.trim().length < 3 || value.trim().length > 4) {
      return 'CVV must be 3 or 4 digits';
    }
    return null;
  }

  // Validate UPI ID
  static String? validateUpiId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UPI ID is required';
    }
    if (!value.contains('@') || value.startsWith('@') || value.endsWith('@')) {
      return 'Enter valid UPI ID (e.g. name@upi)';
    }
    return null;
  }
}
