import 'dart:convert';

bool isTokenExpired(String? token) {
  if (token == null) return true;

  final parts = token.split('.');
  if (parts.length != 3) return true;

  final payload = base64Url.normalize(parts[1]);
  final decoded = json.decode(utf8.decode(base64Url.decode(payload)));

  final exp = decoded['exp'];
  if (exp == null) return true;

  final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  return DateTime.now().isAfter(expiryDate);
}

