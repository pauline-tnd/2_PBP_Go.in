bool isNetworkImagePath(String? path) {
  if (path == null) return false;
  final normalized = path.trim().toLowerCase();
  return normalized.startsWith('http://') ||
      normalized.startsWith('https://') ||
      normalized.startsWith('//') ||
      normalized.startsWith('data:image/');
}

String normalizeImagePath(String? path) {
  if (path == null) return '';

  var normalized = path.trim().replaceAll('\\', '/');
  if (normalized.isEmpty) return '';

  if (normalized.startsWith('./')) {
    normalized = normalized.substring(2);
  }

  if (normalized.startsWith('/')) {
    normalized = normalized.substring(1);
  }

  if (normalized.startsWith('assets/assets/')) {
    normalized = normalized.replaceFirst('assets/assets/', 'assets/');
  }

  return normalized;
}
