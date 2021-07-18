import 'dart:math';

import 'base.dart';
import 'privatekey.dart';
import 'publickey.dart';

/// [EllipticCurve] is the implement for [Curve].
class EllipticCurve implements Curve {
  @override
  late String name;

  @override
  late BigInt p; // the order of the underlying field

  @override
  late BigInt a; // the constant of the curve equation

  @override
  late BigInt b; // the constant of the curve equation

  @override
  late BigInt S; // TODO: use the seed

  @override
  late AffinePoint
      G; // Gx&Gy are the x&y coordinate of the base point, respectively

  @override
  late int bitSize; // bitSize is the size of the underlying field in bits.

  @override
  late BigInt n; // the order of the base point G

  @override
  late int h; // the cofactor

  /// S currenly is not used by this package
  EllipticCurve(this.name, this.bitSize, this.p, this.a, this.b, this.S, this.G,
      this.n, this.h);

  @override
  AffinePoint add(AffinePoint p1, AffinePoint p2) {
    var z1 = zForAffine(p1);
    var z2 = zForAffine(p2);
    var _p = _addJacobian(p1.X, p1.Y, z1, p2.X, p2.Y, z2);
    return _affineFromJacobian(_p.X, _p.Y, _p.Z);
  }

  @override
  AffinePoint dou(AffinePoint point) {
    var z = zForAffine(point);
    var _p = _doubleJacobian(point.X, point.Y, z);
    return _affineFromJacobian(_p.X, _p.Y, _p.Z);
  }

  @override
  bool isOnCurve(AffinePoint point) {
    // y² = x³ - 3x + b
    var y2 = point.Y * point.Y;
    y2 = y2 % p;

    return _polynomial(point.X) == y2;
  }

  /// [scalarMult] returns [k]*([basePoint].X, [basePoint].Y) where [k] is a number
  /// in big-endian form ([BigInt] bytes).
  @override
  AffinePoint scalarMul(AffinePoint basePoint, List<int> k) {
    var _p = JacobianPoint.fromXYZ(basePoint.X, basePoint.Y, BigInt.zero);

    for (var byte in k) {
      for (var bitNum = 0; bitNum < 8; bitNum++) {
        _p = _doubleJacobian(_p.X, _p.Y, _p.Z);
        if (byte & 0x80 == 0x80) {
          _p = _addJacobian(
              basePoint.X, basePoint.Y, BigInt.one, _p.X, _p.Y, _p.Z);
        }
        byte <<= 1;
      }
    }

    return _affineFromJacobian(_p.X, _p.Y, _p.Z);
  }

  @override
  AffinePoint scalarBaseMul(List<int> k) {
    return scalarMul(AffinePoint.fromXY(G.X, G.Y), k);
  }

  // addJacobian takes two points in Jacobian coordinates, (x1, y1, z1) and
  // (x2, y2, z2) and returns their sum, also in Jacobian form.
  JacobianPoint _addJacobian(
      BigInt x1, BigInt y1, BigInt z1, BigInt x2, BigInt y2, BigInt z2) {
    // See https://hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-3.html#addition-add-2007-bl
    BigInt x3, y3, z3;
    if (z1.sign == 0) {
      x3 = x2;
      y3 = y2;
      z3 = z2;
      return JacobianPoint.fromXYZ(x3, y3, z3);
    }
    if (z2.sign == 0) {
      x3 = x1;
      y3 = y1;
      z3 = z1;
      return JacobianPoint.fromXYZ(x3, y3, z3);
    }

    var z1z1 = z1 * z1;
    z1z1 = z1z1 % p;
    var z2z2 = z2 * z2;
    z2z2 = z2z2 % p;

    var u1 = x1 * z2z2;
    u1 = u1 % p;
    var u2 = x2 * z1z1;
    u2 = u2 % p;
    var h = u2 - u1;
    var xEqual = h.sign == 0;
    if (h.sign == -1) {
      h = h + p;
    }

    var i = h << 1;
    i = i * i;
    var j = h * i;

    var s1 = y1 * z2;
    s1 = s1 * z2z2;
    s1 = s1 % p;
    var s2 = y2 * z1;
    s2 = s2 * z1z1;
    s2 = s2 % p;
    var r = s2 - s1;
    if (r.sign == -1) {
      r = r + p;
    }
    var yEqual = r.sign == 0;
    if (xEqual && yEqual) {
      return _doubleJacobian(x1, y1, z1);
    }
    r = r << 1;
    var v = u1 * i;

    x3 = r;
    x3 = x3 * x3;
    x3 = x3 - j;
    x3 = x3 - v;
    x3 = x3 - v;
    x3 = x3 % p;

    y3 = r;
    v = v - x3;
    y3 = y3 * v;
    s1 = s1 * j;
    s1 = s1 << 1;
    y3 = y3 - s1;
    y3 = y3 % p;

    z3 = z1 + z2;
    z3 = z3 * z3;
    z3 = z3 - z1z1;
    z3 = z3 - z2z2;
    z3 = z3 * h;
    z3 = z3 % p;

    return JacobianPoint.fromXYZ(x3, y3, z3);
  }

  JacobianPoint _doubleJacobian(BigInt x, BigInt y, BigInt z) {
    switch (a.toInt()) {
      case -3:
        {
          return _doubleJacobian_random(x, y, z);
        }

      case 0:
        {
          return _doubleJacobian_koblitz(x, y, z);
        }
      default:
        throw Exception('unknown curve type: a = $a');
    }
  }

  JacobianPoint _doubleJacobian_random(BigInt x, BigInt y, BigInt z) {
    // See https://hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-3.html#doubling-dbl-2001-b
    var delta = z * z;
    delta = delta % p;
    var gamma = y * y;
    gamma = gamma % p;
    var alpha = x - delta;
    if (alpha.sign == -1) {
      alpha = alpha + p;
    }
    var alpha2 = x + delta;
    alpha = alpha * alpha2;
    alpha2 = alpha;
    alpha = alpha << 1;
    alpha = alpha + alpha2;

    alpha2 = x * gamma;
    var beta = alpha2;

    var x3 = alpha * alpha;
    var beta8 = beta << 3;
    beta8 = beta8 % p;
    x3 = x3 - beta8;
    if (x3.sign == -1) {
      x3 = x3 + p;
    }
    x3 = x3 % p;

    var z3 = y + z;
    z3 = z3 * z3;
    z3 = z3 - gamma;
    if (z3.sign == -1) {
      z3 = z3 + p;
    }
    z3 = z3 - delta;
    if (z3.sign == -1) {
      z3 = z3 + p;
    }
    z3 = z3 % p;

    beta = beta << 2;
    beta = beta - x3;
    if (beta.sign == -1) {
      beta = beta + p;
    }
    alpha = alpha * beta;
    var y3 = alpha;

    gamma = gamma * gamma;
    gamma = gamma << 3;
    gamma = gamma % p;

    y3 = y3 - gamma;
    if (y3.sign == -1) {
      y3 = y3 + p;
    }
    y3 = y3 % p;

    return JacobianPoint.fromXYZ(x3, y3, z3);
  }

  JacobianPoint _doubleJacobian_koblitz(BigInt x, BigInt y, BigInt z) {
    BigInt x3, y3, z3;
    // X3 = (3*X1^2+a)^2 - 8*X1*Y1^2
    // Y3 = (3*X1^2)*(4*X1*Y1^2 - X3) - 8*Y1^4
    // Z3 = 2*Y1*Z1
    z3 = y * z * BigInt.two;

    var xx = x.modPow(BigInt.two, p);
    var yy = y.modPow(BigInt.two, p);
    var yyyy = y.modPow(BigInt.from(4), p);

    x3 = (BigInt.from(3) * xx + a).modPow(BigInt.two, p) -
        BigInt.from(8) * x * yy;
    if (x3.sign < 0) {
      x3 += p;
    }

    var e = BigInt.from(4) * x * yy - x3;
    if (e.sign < 0) {
      e += p;
    }

    y3 = (BigInt.from(3) * xx) * e - BigInt.from(8) * yyyy;

    return JacobianPoint.fromXYZ(x3, y3, z3);
  }

  AffinePoint _affineFromJacobian(BigInt x, BigInt y, BigInt z) {
    if (z.sign == 0) {
      return AffinePoint.fromXY(x, y);
    }

    var zinv = z.modInverse(p);
    var zinvsq = zinv.modPow(BigInt.two, p);

    var xOut = x * zinvsq % p;
    zinvsq = zinvsq * zinv;
    var yOut = y * zinvsq % p;

    return AffinePoint.fromXY(xOut, yOut);
  }

  // polynomial returns y^2 = x³ + ax + b
  // y^2 = x³ - 3x + b, a always -3 in ECDSA, but
  // (k1 uses y^2 = x^3 + 7), a = 0, so a should be a var for curve
  BigInt _polynomial(BigInt x) {
    var x3 = x * x * x;

    var aX = x * a;

    x3 = x3 + aX + b;
    x3 = x3 % p;

    return x3;
  }

  @override
  PrivateKey generatePrivateKey() {
    var random = Random.secure();
    var byteLen = (bitSize + 7) ~/ 8;
    var _p = AffinePoint();
    BigInt D;
    late List<int> rand;
    while (_p.X == BigInt.zero) {
      rand = List<int>.generate(byteLen, (i) => random.nextInt(256));
      // We have to mask off any excess bits in the case that the size of the
      // underlying field is not a whole number of bytes.
      rand[0] &= mask[bitSize % 8];
      // This is because, in tests, rand will return all zeros and we don't
      // want to get the point at infinity and loop forever.
      rand[1] ^= 0x42;
      D = BigInt.parse(
          List<String>.generate(byteLen, (i) => rand[i].toRadixString(16))
              .join(),
          radix: 16);

      // If the scalar is out of range, sample another random number.
      if (D >= n) {
        continue;
      }

      _p = scalarBaseMul(rand);
    }

    return PrivateKey.fromBytes(this, rand);
  }

  @override
  PublicKey privateToPublicKey(PrivateKey priv) {
    return PublicKey.fromPoint(this, scalarBaseMul(priv.bytes));
  }

  /// [publicKeyToHex] converts a point on the curve into the uncompressed form
  /// specified in section 4.3.6 of ANSI X9.62.
  @override
  String publicKeyToHex(PublicKey pub) {
    var byteLen = (bitSize + 7) ~/ 8;

    var ret = '04'; // uncompressed point

    ret += pub.X.toRadixString(16).padLeft(byteLen * 2, '0');
    ret += pub.Y.toRadixString(16).padLeft(byteLen * 2, '0');

    return ret;
  }

  /// [publicKeyToCompressedHex] converts a point on the curve into the compressed form
  /// specified in section 4.3.6 of ANSI X9.62.
  @override
  String publicKeyToCompressedHex(PublicKey pub) {
    var byteLen = (bitSize + 7) ~/ 8;

    var compressed =
        pub.Y.toRadixString(2).padLeft(bitSize, '0')[0] == '0' ? '02' : '03';
    compressed += pub.X.toRadixString(16).padLeft(byteLen * 2, '0');

    return compressed;
  }

  @override
  PublicKey hexToPublicKey(String hex) {
    if (hex.substring(0, 2) != '04') {
      throw ('invalid public key hex string');
    }
    var byteLen = (bitSize + 7) ~/ 8;
    if (hex.length != 2 * (1 + 2 * byteLen)) {
      throw ('invalid public key hex string');
    }

    var x = BigInt.parse(hex.substring(2 * 1, 2 * (1 + byteLen)), radix: 16);
    var y = BigInt.parse(hex.substring(2 * (1 + byteLen)), radix: 16);
    var pub = PublicKey(this, x, y);
    if (!isOnCurve(pub)) {
      throw ('public key is not on this curve');
    }

    return pub;
  }

  @override
  PublicKey compressedHexToPublicKey(String hex) {
    if (hex.substring(0, 2) != '03' && hex.substring(0, 2) != '02') {
      throw ('invalid public key hex string');
    }

    var byteLen = (bitSize + 7) ~/ 8;

    if (hex.length != 2 * (1 + byteLen)) {
      throw ('invalid public key hex string');
    }
    // y² = x³ - 3x + b

    var x = BigInt.parse(hex.substring(2 * 1, 2 * (1 + byteLen)), radix: 16);
    if (x > p) {
      throw ('invalid public key X value');
    }

    var y = _polynomial(x);

    var p1 = p + BigInt.one; // p+1
    var power = (p1 - p1 % BigInt.from(4)) ~/ BigInt.from(4);
    y = y.modPow(power, p); // get the sqrt mod

    if ((y.toRadixString(2).padLeft(bitSize, '0')[0] == '0' && hex[1] == '3') ||
        (y.toRadixString(2).padLeft(bitSize, '0')[0] == '1' && hex[1] == '2')) {
      y = (-y) % p;
    }

    var pub = PublicKey(this, x, y);
    if (!isOnCurve(pub)) {
      throw ('public key is not on this curve');
    }

    return pub;
  }
}

var mask = [0xff, 0x1, 0x3, 0x7, 0xf, 0x1f, 0x3f, 0x7f];

// zForAffine returns a Jacobian Z value for the affine point (x, y). If x and
// y are zero, it assumes that they represent the point at infinity because (0,
// 0) is not on the any of the curves handled here.
BigInt zForAffine(AffinePoint p) {
  var z = BigInt.zero;
  if (p.X.sign != 0 || p.Y.sign != 0) {
    z = BigInt.from(1);
  }

  return z;
}
