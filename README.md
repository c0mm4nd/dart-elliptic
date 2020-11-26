# dart-elliptic

In cryptography, the  Digital Signature Algorithm (ECDSA) offers a variant of the Digital Signature Algorithm (DSA) which uses elliptic curve cryptography.

This lib mainly defines the `abstract class Curve`, acting as *Elliptic Curve* which will be used in other packages like ecdsa, schnorr and secp256k1 etc.

## Usage

A simple usage example:

```dart
import 'package:elliptic/elliptic.dart';

void main() {
  var ec = getP256();
  var priv = ec.generatePrivateKey();
  var pub = priv.publicKey;
  print('privateKey: 0x${priv}');
  print('publicKey: 0x${pub}');
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/C0MM4ND/dart-elliptic/issues
