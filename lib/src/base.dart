import 'privatekey.dart';
import 'publickey.dart';

abstract class Curve {
  int get BitSize;
  bool isOnCurve(AffinePoint p);
  AffinePoint add(AffinePoint p1, AffinePoint p2);
  AffinePoint dou(AffinePoint p);
  AffinePoint scalarMul(AffinePoint p, List<int> k);
  AffinePoint scalarBaseMul(List<int> k);
  PrivateKey generatePrivateKey();
  PublicKey privateToPublicKey(PrivateKey priv);
  String publicKeyToHex(PublicKey pub);
  String publicKeyToCompressedHex(PublicKey pub);
  PublicKey hexToPublicKey(String hex);
  PublicKey compressedHexToPublicKey(String hex);
}

class AffinePoint {
  late BigInt X;
  late BigInt Y;

  AffinePoint() {
    X = BigInt.zero;
    Y = BigInt.zero;
  }
  AffinePoint.fromXY(this.X, this.Y);

  @override
  bool operator ==(other) {
    return other is AffinePoint && (X == other.X && Y == other.Y);
  }
}

class JacobianPoint {
  late BigInt X, Y, Z;

  JacobianPoint() {
    X = BigInt.zero;
    Y = BigInt.zero;
    Z = BigInt.zero;
  }
  JacobianPoint.fromXYZ(this.X, this.Y, this.Z);

  @override
  bool operator ==(other) {
    return other is JacobianPoint &&
        (X == other.X && Y == other.Y && Z == other.Z);
  }
}

class ErrInvalidPublicKeyHexLength implements Exception {}

class ErrInvalidPublicKeyHexPrefix implements Exception {}

class ErrInvalidPrivateKeyHex implements Exception {}
