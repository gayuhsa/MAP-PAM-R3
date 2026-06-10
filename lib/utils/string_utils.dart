String normalizeEntityName(String value) {
  final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (trimmed.isEmpty) return '';

  return trimmed
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) {
        final lower = word.toLowerCase();
        return lower[0].toUpperCase() + lower.substring(1);
      })
      .join(' ');
}

String normalizeDescription(String value) {
  final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (trimmed.isEmpty) return '';
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}
