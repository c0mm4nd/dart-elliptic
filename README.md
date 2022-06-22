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
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/C0MM4ND/dart-elliptic/issues
