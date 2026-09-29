import 'package:uuid/uuid.dart';

class FileValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? sanitizedFileName;
  final String? mimeType;
  final int fileSizeInBytes;

  const FileValidationResult({
    required this.isValid,
    this.errorMessage,
    this.sanitizedFileName,
    this.mimeType,
    this.fileSizeInBytes = 0,
  });

  factory FileValidationResult.valid({
    required String sanitizedFileName,
    required String mimeType,
    required int fileSize,
  }) {
    return FileValidationResult(
      isValid: true,
      sanitizedFileName: sanitizedFileName,
      mimeType: mimeType,
      fileSizeInBytes: fileSize,
    );
  }

  factory FileValidationResult.invalid(String error) {
    return FileValidationResult(isValid: false, errorMessage: error);
  }
}

/// Security Validator for Safety Photos and Document Attachments
class FileUploadSecurityValidator {
  FileUploadSecurityValidator._();

  static const _uuid = Uuid();
  static const int maxFileSizeInBytes = 10 * 1024 * 1024; // 10 Megabytes

  static const Set<String> _allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'pdf',
  };

  static const Map<String, String> _extensionMimeMap = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'pdf': 'application/pdf',
  };

  static const Set<String> _blockedDangerousExtensions = {
    'exe', 'bat', 'cmd', 'sh', 'php', 'js', 'vbs', 'scr', 'msi', 'ps1', 'apk', 'dll', 'bin'
  };

  /// Validates an attachment before upload
  static FileValidationResult validateFile({
    required String originalFileName,
    required int fileSizeBytes,
  }) {
    // 1. Check file size
    if (fileSizeBytes <= 0) {
      return FileValidationResult.invalid('File is empty (0 bytes).');
    }
    if (fileSizeBytes > maxFileSizeInBytes) {
      final sizeMb = (fileSizeBytes / (1024 * 1024)).toStringAsFixed(1);
      return FileValidationResult.invalid('File size ($sizeMb MB) exceeds the maximum allowed limit of 10 MB.');
    }

    // 2. Extract and sanitize extension
    final parts = originalFileName.split('.');
    if (parts.length < 2) {
      return FileValidationResult.invalid('File missing a valid extension format.');
    }
    final extension = parts.last.toLowerCase().trim();

    // 3. Block executable and dangerous script extensions
    if (_blockedDangerousExtensions.contains(extension)) {
      return FileValidationResult.invalid('Security Alert: Executable and script files are strictly prohibited.');
    }

    // 4. Verify extension is in whitelist
    if (!_allowedExtensions.contains(extension)) {
      return FileValidationResult.invalid(
        'Unsupported file type ".$extension". Only JPEG, PNG images and PDF documents are permitted for safety attachments.',
      );
    }

    // 5. Generate sanitized, randomized UUID filename to prevent path traversal & collision
    final safeName = 'oil_att_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 8)}.$extension';
    final mimeType = _extensionMimeMap[extension] ?? 'application/octet-stream';

    return FileValidationResult.valid(
      sanitizedFileName: safeName,
      mimeType: mimeType,
      fileSize: fileSizeBytes,
    );
  }
}
