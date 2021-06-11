import 'base.dart';
import 'publickey.dart';

class PrivateKey {
  late Curve curve;
  late BigInt D;

  PrivateKey(this.curve, this.D);

  PrivateKey.fromBytes(this.curve, List<int> bytes) {
    var byteLen = (curve.bitSize + 7) ~/ 8;
    D = BigInt.parse(
        List<String>.generate(
            byteLen, (i) => bytes[i].toRadixString(16).padLeft(2, '0')).join(),
        radix: 16);
  }

  PrivateKey.fromHex(this.curve, String hexRand) {
    D = BigInt.parse(hexRand, radix: 16);
  }

  /// [bytes] will calculate the bytes for the private key's [D]
  List<int> get bytes {
    var byteLen = (curve.bitSize + 7) ~/ 8;
    var hex = D.toRadixString(16).padLeft(byteLen * 2, '0'); // to bigendian
    return List<int>.generate(
        byteLen, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16));
  }

  /// [publicKey] will calculate the public key for the private key
  PublicKey get publicKey {
    return curve.privateToPublicKey(this);
  }

  String toHex() {
    return D.toRadixString(16);
  }

  @override
  String toString() {
    return toHex();
  }

  @override
  bool operator ==(other) {
    return other is PrivateKey && (curve == other.curve && D == other.D);
  }
}
