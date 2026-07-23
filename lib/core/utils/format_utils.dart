import '../constants/app_constants.dart';

String resolveImageUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http')) return url;
  return '${AppConstants.apiOrigin}$url';
}

String formatVnd(num? value) {
  if (value == null) return '—';
  return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ₫';
}
