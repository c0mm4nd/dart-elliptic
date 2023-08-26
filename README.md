# dart-elliptic

In cryptography, the  Digital Signature Algorithm (ECDSA) offers a variant of the Digital Signature Algorithm (DSA) which uses elliptic curve cryptography.

This lib mainly defines the `abstract class Curve`, serving *Elliptic Curve* which will be used in other packages like [ecdsa](https://pub.dev/packages/ecdsa), schnorr(WIP) and secp256k1 etc.

You can also get the key pairs on the curve, but if you need to signiture message, please use the signature util package, like [ecdsa](https://pub.dev/packages/ecdsa). 

This package is pure dart and no 3rd dependency.

## Usage

A simple usage example:

```dart
import 'package:elliptic/elliptic.dart';
import 'package:elliptic/ecdh.dart';
// if working with PEM
import 'package:pem/pem.dart';

void main() {
  // use elliptic curves 
  var ec = getP256();
  var priv = ec.generatePrivateKey();
  var pub = priv.publicKey;
  print('privateKey: 0x$priv');
  print('publicKey: 0x$pub');

  // use ecdh
  var privateAlice = ec.generatePrivateKey();
  var publicAlice = privateAlice.publicKey;
  var privateBob = ec.generatePrivateKey();
  var publicBob = privateBob.publicKey;
  var secretAlice = computeSecretHex(privateAlice, publicBob);
  var secretBob = computeSecretHex(privateBob, publicAlice);
  print('secretAlice: 0x$secretAlice');
  print('secretBob: 0x$secretBob');

  // working with PEM requires https://pub.dev/packages/pem
  // Parse PEM encoded private key.
  var rawPriv = PemCodec(PemLabel.privateKey).decode('''
    -----BEGIN PRIVATE KEY-----
    MIGEAgEAMBAGByqGSM49AgEGBSuBBAAKBG0wawIBAQQgVcB/UNPxalR9zDYAjQIf
    jojUDiQuGnSJrFEEzZPT/92hRANCAASc7UJtgnF/abqWM60T3XNJEzBv5ez9TdwK
    H0M6xpM2q+53wmsN/eYLdgtjgBd3DBmHtPilCkiFICXyaA8z9LkJ
    -----END PRIVATE KEY-----
  ''');
  // Parse PEM encoded public key.
  var privateFromPEM = PrivateKey.fromBytes(ec, rawPriv);
  print('privateAliceFromPEM: 0x$privateFromPEM');

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
  var X = BigInt.parse(hexPublickKey.substring(0, 64), radix: 16);
  var Y = BigInt.parse(hexPublickKey.substring(64), radix: 16);
  var publicFromPEM = PublicKey(ec, X, Y);
  print('publicFromPEM: 0x$publicFromPEM');
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/C0MM4ND/dart-elliptic/issues
