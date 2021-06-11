import 'privatekey.dart';
import 'publickey.dart';

// all params follows http://www.secg.org/sec2-v2.pdf
abstract class Curve {
  String get name;
  int get bitSize; // BitSize is the size of the underlying secp256k1 field in bits.

  BigInt get p; // the order of the underlying field
  BigInt get a; // the factor of x^1
  BigInt get b; // the constant of the curve equation
  BigInt get S; // the seed for choosing E from Fp, ANSI X9.62
  AffinePoint
      get G; // Gx&Gy are the x&y coordinate of the base point, respectively

  BigInt get n; // the order of the base point
  int get h;

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

class ErrInvalidPrivateKeyHexLength implements Exception {
} // won't appear because the contructor will auto left padding 
