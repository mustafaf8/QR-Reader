import 'package:flutter/services.dart';

class BarcodeConstraint {
  const BarcodeConstraint({
    this.minLength,
    this.maxLength,
    this.allowedPattern,
    this.description,
    this.forceUppercase = false,
    this.digitsOnly = false,
    this.validator,
  });

  final int? minLength;
  final int? maxLength;
  final RegExp? allowedPattern;
  final String? description;
  final bool forceUppercase;
  final bool digitsOnly;
  final bool Function(String value)? validator;

  List<TextInputFormatter> buildInputFormatters() {
    final formatters = <TextInputFormatter>[];
    if (digitsOnly) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    } else if (allowedPattern != null) {
      formatters.add(FilteringTextInputFormatter.allow(allowedPattern!));
    }
    if (forceUppercase) {
      formatters.add(UpperCaseTextFormatter());
    }
    if (maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(maxLength));
    }
    return formatters;
  }

  bool validate(String input) {
    if (minLength != null && input.length < minLength!) return false;
    if (maxLength != null && input.length > maxLength!) return false;
    if (allowedPattern != null && !allowedPattern!.hasMatch(input)) {
      return false;
    }
    if (validator != null && !validator!(input)) return false;
    return true;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class BarcodeConstraints {
  static const BarcodeConstraint qr = BarcodeConstraint(
    description: 'supports any UTF-8 text',
  );

  static const BarcodeConstraint ean8 = BarcodeConstraint(
    minLength: 7,
    maxLength: 7,
    digitsOnly: true,
    description: 'EAN-8 requires 7 numeric digits, last check digit auto',
  );

  static const BarcodeConstraint ean13 = BarcodeConstraint(
    minLength: 12,
    maxLength: 12,
    digitsOnly: true,
    description: 'EAN-13 requires 12 numeric digits, last check digit auto',
  );

  static const BarcodeConstraint upcA = BarcodeConstraint(
    minLength: 11,
    maxLength: 11,
    digitsOnly: true,
    description: 'UPC-A requires 11 numeric digits, check digit auto',
  );

  static const BarcodeConstraint upcE = BarcodeConstraint(
    minLength: 6,
    maxLength: 6,
    digitsOnly: true,
    description: 'UPC-E requires 6 numeric digits',
  );

  static final BarcodeConstraint code39 = BarcodeConstraint(
    minLength: 1,
    maxLength: 48,
    description: 'CODE-39 supports digits, A-Z, and - . space \$ + / %',
    forceUppercase: true,
    validator: (value) => RegExp(r'^[0-9A-Z.\- $+/%]*$').hasMatch(value),
  );

  static final BarcodeConstraint code93 = BarcodeConstraint(
    minLength: 1,
    maxLength: 80,
    allowedPattern: RegExp(r'^[\x00-\x7F]*$'),
    description: 'CODE-93 supports full ASCII',
    forceUppercase: false,
  );

  static final BarcodeConstraint code128 = BarcodeConstraint(
    minLength: 1,
    maxLength: 80,
    allowedPattern: RegExp(r'^[\x00-\x7F]*$'),
    description: 'CODE-128 supports full ASCII',
  );

  static final BarcodeConstraint itf = BarcodeConstraint(
    minLength: 2,
    maxLength: 80,
    digitsOnly: true,
    description: 'ITF requires even number of digits',
  );

  static final BarcodeConstraint pdf417 = BarcodeConstraint(
    minLength: 1,
    maxLength: 500,
    description: 'PDF417 supports up to 500 characters',
  );

  static final BarcodeConstraint codabar = BarcodeConstraint(
    minLength: 4,
    maxLength: 80,
    allowedPattern: RegExp(r'^[0-9\-\$:\/\.\+]*$'),
    description: 'Codabar supports digits and - \$ : / . +',
    forceUppercase: true,
  );

  static final BarcodeConstraint dataMatrix = BarcodeConstraint(
    minLength: 1,
    maxLength: 80,
    description: 'Data Matrix supports ASCII text up to 80 chars',
  );

  static final BarcodeConstraint aztec = BarcodeConstraint(
    minLength: 1,
    maxLength: 80,
    description: 'Aztec supports ASCII text up to 80 chars',
  );

  static BarcodeConstraint constraintFor(String format) {
    switch (format) {
      case 'EAN-8':
        return ean8;
      case 'EAN-13':
        return ean13;
      case 'UPC-A':
        return upcA;
      case 'UPC-E':
        return upcE;
      case 'CODE-39':
        return code39;
      case 'CODE-93':
        return code93;
      case 'CODE-128':
        return code128;
      case 'ITF':
        return itf;
      case 'PDF417':
        return pdf417;
      case 'CODABAR':
        return codabar;
      case 'DATA MATRIX':
        return dataMatrix;
      case 'AZTEC':
        return aztec;
      case 'QR':
      default:
        return qr;
    }
  }
}

