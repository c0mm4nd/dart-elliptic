import 'package:elliptic/elliptic.dart';
import 'package:pem/pem.dart';
import 'package:test/test.dart';

void main() {
  test('Should reject RSA public key in ECDH computation', () {
    // Using secp256r1.
    var ec = getP256();

    // Parse PEM encoded EC private key.
    var rawPriv = PemCodec(PemLabel.privateKey).decode('''
      -----BEGIN PRIVATE KEY-----
      MIGEAgEAMBAGByqGSM49AgEGBSuBBAAKBG0wawIBAQQgVcB/UNPxalR9zDYAjQIf
      jojUDiQuGnSJrFEEzZPT/92hRANCAASc7UJtgnF/abqWM60T3XNJEzBv5ez9TdwK
      H0M6xpM2q+53wmsN/eYLdgtjgBd3DBmHtPilCkiFICXyaA8z9LkJ
      -----END PRIVATE KEY-----
    ''');
    var privateFromPEM = PrivateKey.fromBytes(ec, rawPriv);
    print('privateAliceFromPEM: 0x$privateFromPEM');

    // Parse PEM encoded RSA public key (NOT an EC key!)
    var keyData = PemCodec(PemLabel.publicKey).decode('''
      -----BEGIN PUBLIC KEY-----
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsjtGIk8SxD+OEiBpP2/T
      JUAF0upwuKGMk6wH8Rwov88VvzJrVm2NCticTk5FUg+UG5r8JArrV4tJPRHQyvqK
      wF4NiksuvOjv3HyIf4oaOhZjT8hDne1Bfv+cFqZJ61Gk0MjANh/T5q9vxER/7TdU
      NHKpoRV+NVlKN5bEU/NQ5FQjVXicfswxh6Y6fl2PIFqT2CfjD+FkBPU1iT9qyJYH
      A38IRvwNtcitFgCeZwdGPoxiPPh1WHY8VxpUVBv/2JsUtrB/rAIbGqZoxAIWvijJ
      Pe9o1TY3VlOzk9ASZ1AeatvOir+iDVJ5OpKmLnzc46QgGPUsjIyo6Sje9dxpGtoG
      QQIDAQAB
      -----END PUBLIC KEY-----
    ''');
    
    var hexPublickKey =
        keyData.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    print('Decoded key data (hex): $hexPublickKey');
    
    // Extract X and Y coordinates (incorrectly treating RSA key as EC key)
    var X = BigInt.parse(hexPublickKey.substring(0, 64), radix: 16);
    var Y = BigInt.parse(hexPublickKey.substring(64), radix: 16);
    
    print('X: ${X.toRadixString(16)}');
    print('Y: ${Y.toRadixString(16)}');
    
    // Creating a PublicKey with invalid coordinates should throw
    expect(
      () => PublicKey(ec, X, Y),
      throwsA(isA<EllipticException>()),
      reason: 'Should not be able to create PublicKey with invalid point');
  });
}
