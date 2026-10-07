import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('Email validation tests', () {
      expect(Validators.validateEmail(''), 'Email address is required');
      expect(Validators.validateEmail(null), 'Email address is required');
      expect(Validators.validateEmail('invalid-email'), 'Please enter a valid email address');
      expect(Validators.validateEmail('user@domain'), 'Please enter a valid email address');
      expect(Validators.validateEmail('valid.user@shopease.com'), isNull);
      expect(Validators.validateEmail('test_123@sub.domain.co'), isNull);
    });

    test('Password validation tests', () {
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword(null), 'Password is required');
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters long');
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('strongPassword!2026'), isNull);
    });

    test('Confirm Password validation tests', () {
      expect(Validators.validateConfirmPassword('', 'secret123'), 'Please confirm your password');
      expect(Validators.validateConfirmPassword('wrong', 'secret123'), 'Passwords do not match');
      expect(Validators.validateConfirmPassword('secret123', 'secret123'), isNull);
    });

    test('Name validation tests', () {
      expect(Validators.validateName(''), 'Name is required');
      expect(Validators.validateName('A'), 'Name must be at least 2 characters');
      expect(Validators.validateName('Alex Johnson'), isNull);
    });

    test('Phone number validation tests', () {
      expect(Validators.validatePhone(''), 'Phone number is required');
      expect(Validators.validatePhone('12345'), 'Enter a valid phone number (at least 10 digits)');
      expect(Validators.validatePhone('9876543210'), isNull);
      expect(Validators.validatePhone('+1 (555) 019-2834'), isNull);
    });

    test('Postal code validation tests', () {
      expect(Validators.validatePostalCode(''), 'Postal code is required');
      expect(Validators.validatePostalCode('12'), 'Enter a valid postal code');
      expect(Validators.validatePostalCode('94102'), isNull);
    });

    test('Card number validation tests', () {
      expect(Validators.validateCardNumber(''), 'Card number is required');
      expect(Validators.validateCardNumber('1234'), 'Enter a valid 16-digit card number');
      expect(Validators.validateCardNumber('1234567812345678'), isNull);
    });

    test('Expiry date validation tests', () {
      expect(Validators.validateExpiryDate(''), 'Expiry date required (MM/YY)');
      expect(Validators.validateExpiryDate('13/26'), 'Invalid month (01-12)');
      expect(Validators.validateExpiryDate('12/28'), isNull);
    });

    test('UPI ID validation tests', () {
      expect(Validators.validateUpiId(''), 'UPI ID is required');
      expect(Validators.validateUpiId('plainstring'), 'Enter valid UPI ID (e.g. name@upi)');
      expect(Validators.validateUpiId('user@bank'), isNull);
    });
  });
}
