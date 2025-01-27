import 'package:encrypt/encrypt.dart';

// void main() {
//   final key = "MtraGXVtfMtQc11a";
//   final plainText = "lorem ipsum example example";
//   Encrypted encrypted = encrypt(key, plainText);
//   String decryptedText = decrypt(key, encrypted);
//   print(decryptedText);
// }

String decrypt(String keyString, Encrypted encryptedData) {
  final key = Key.fromUtf8(keyString);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final initVector = IV.fromUtf8(keyString.substring(0, 16));
  return encrypter.decrypt(encryptedData, iv: initVector);
}

Encrypted encrypt(String keyString, String plainText) {
  final key = Key.fromUtf8(keyString);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final initVector = IV.fromUtf8(keyString.substring(0, 16));
  Encrypted encryptedData = encrypter.encrypt(plainText, iv: initVector);
  return encryptedData;
}

String decryptAES(String base64Text, String key) {
  print(base64Text);
  String decrypted = decrypt(key, Encrypted.fromBase64(base64Text));
  print(decrypted);
  return decrypted;
}
