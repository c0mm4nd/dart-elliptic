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

  /// [scalarMult] returns [k]*([p].X, [p].Y) where [k] is a number
  /// in big-endian form ([BigInt] bytes).
  @override
  AffinePoint scalarMul(AffinePoint p, List<int> k) {
    var _p = JacobianPoint.fromXYZ(BigInt.zero, BigInt.zero, BigInt.zero);

    for (var byte in k) {
      for (var bitNum = 0; bitNum < 8; bitNum++) {
        _p = _doubleJacobian(_p.X, _p.Y, _p.Z);
        if (byte & 0x80 == 0x80) {
          _p = _addJacobian(p.X, p.Y, BigInt.one, _p.X, _p.Y, _p.Z);
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

  AffinePoint _affineFromJacobian(BigInt x, BigInt y, BigInt z) {
    if (z.sign == 0) {
      return AffinePoint.fromXY(x, y);
    }

    var zinv = z.modInverse(p);
    var zinvsq = zinv * zinv;

    var xOut = x * zinvsq;
    xOut = xOut % p;
    zinvsq = zinvsq * zinv;
    var yOut = y * zinvsq;
    yOut = yOut % p;
    return AffinePoint.fromXY(xOut, yOut);
  }

  // polynomial returns y^2 = x³ + ax + b
  // y^2 = x³ - 3x + b, a always -3 in ECDSA, but
  // (k1 uses y^2 = x^3 + 7), a = 0, so a should be a var for curve
  BigInt _polynomial(BigInt x) {
    var x3 = x * x * x;

    var aX = x * a;

    x3 = x3 + aX;
    x3 = x3 + b;
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
        pub.Y.toRadixString(2).padLeft(bitSize)[0] == '0' ? '02' : '03';
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
    var y = _polynomial(x);

    var p1 = p + BigInt.from(1); // p+1
    var power = (p1 - p1 % BigInt.from(4)) ~/ BigInt.from(4);
    y = y.modPow(power, p);

    if (!(y.toRadixString(2).padLeft(bitSize)[0] == '0' && hex[1] == '2') &&
        !(y.toRadixString(2).padLeft(bitSize)[0] == '1' && hex[1] == '3')) {
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

late EllipticCurve _p224 = EllipticCurve(
  'secp224r1', // See FIPS 186-3, section D.2.2
  224,
  BigInt.parse(
      '26959946667150639794667015087019630673557916260026308143510066298881',
      radix: 10), // P
  BigInt.from(-3),
  BigInt.parse('b4050a850c04b3abf54132565044b0b7d7bfd8ba270b39432355ffb4',
      radix: 16),
  BigInt.zero,
  AffinePoint.fromXY(
      BigInt.parse('b70e0cbd6bb4bf7f321390b94a03c1d356c21122343280d6115c1d21',
          radix: 16),
      BigInt.parse('bd376388b5f723fb4c22dfe6cd4375a05a07476444d5819985007e34',
          radix: 16)),
  BigInt.parse(
      '26959946667150639794667015087019625940457807714424391721682722368061',
      radix: 10), // N
  01, // h
);

/// [getP224] returns a [EllipticCurve] which implements P-224 (see FIPS 186-3, section D.2.2).
///
/// The cryptographic operations are implemented using constant-time algorithms.
Curve getP224() {
  return _p224;
}

/// [getSecp224r1] is same to [getP224]
Curve getSecp224r1() {
  return _p224;
}

late EllipticCurve _p256 = EllipticCurve(
  'secp256r1',
  256,
  BigInt.parse(
      '115792089210356248762697446949407573530086143415290314195533631308867097853951',
      radix: 10),
  BigInt.from(-3),
  BigInt.parse(
      '5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b',
      radix: 16),
  BigInt.zero,
  AffinePoint.fromXY(
      BigInt.parse(
          '6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296',
          radix: 16),
      BigInt.parse(
          '4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5',
          radix: 16)),
  BigInt.parse(
      '115792089210356248762697446949407573529996955224135760342422259061068512044369',
      radix: 10),
  01,
);

/// [getP256] returns a [EllipticCurve] which implements NIST P-256 (FIPS 186-3, section D.2.3),
/// also known as secp256r1 or prime256v1. The CurveParams.Name of this Curve is
/// "P-256".
///
/// Multiple invocations of this function will return the same value, so it can
/// be used for equality checks and switch statements.
///
/// The cryptographic operations are implemented using constant-time algorithms.
EllipticCurve getP256() {
  return _p256;
}

/// [getSecp256r1] is same to [getP256]
Curve getSecp256r1() {
  return _p256;
}

late EllipticCurve _p384 = EllipticCurve(
  'secp384r1',
  384,
  BigInt.parse(
      '39402006196394479212279040100143613805079739270465446667948293404245721771496870329047266088258938001861606973112319',
      radix: 10),
  BigInt.from(-3),
  BigInt.parse(
      'b3312fa7e23ee7e4988e056be3f82d19181d9c6efe8141120314088f5013875ac656398d8a2ed19d2a85c8edd3ec2aef',
      radix: 16),
  BigInt.zero,
  AffinePoint.fromXY(
      BigInt.parse(
          'aa87ca22be8b05378eb1c71ef320ad746e1d3b628ba79b9859f741e082542a385502f25dbf55296c3a545e3872760ab7',
          radix: 16),
      BigInt.parse(
          '3617de4a96262c6f5d9e98bf9292dc29f8f41dbd289a147ce9da3113b5f0b8c00a60b1ce1d7e819d7a431d7c90ea0e5f',
          radix: 16)),
  BigInt.parse(
      '39402006196394479212279040100143613805079739270465446667946905279627659399113263569398956308152294913554433653942643',
      radix: 10),
  01,
);

/// [getP384] returns a [EllipticCurve] which implements NIST P-384 (FIPS 186-3, section D.2.4),
/// also known as secp384r1. The CurveParams.Name of this Curve is "P-384".
///
/// Multiple invocations of this function will return the same value, so it can
/// be used for equality checks and switch statements.
///
/// The cryptographic operations do not use constant-time algorithms.
Curve getP384() {
  return _p384;
}

/// [getSecp384r1] is same to [getP384]
Curve getSecp384r1() {
  return _p384;
}

Curve _p521 = EllipticCurve(
  'secp521r1',
  521,
  BigInt.parse(
      '6864797660130609714981900799081393217269435300143305409394463459185543183397656052122559640661454554977296311391480858037121987999716643812574028291115057151',
      radix: 10),
  BigInt.from(-3),
  BigInt.parse(
      '051953eb9618e1c9a1f929a21a0b68540eea2da725b99b315f3b8b489918ef109e156193951ec7e937b1652c0bd3bb1bf073573df883d2c34f1ef451fd46b503f00',
      radix: 16),
  BigInt.zero,
  AffinePoint.fromXY(
      BigInt.parse(
          'c6858e06b70404e9cd9e3ecb662395b4429c648139053fb521f828af606b4d3dbaa14b5e77efe75928fe1dc127a2ffa8de3348b3c1856a429bf97e7e31c2e5bd66',
          radix: 16),
      BigInt.parse(
          '11839296a789a3bc0045c8a5fb42c7d1bd998f54449579b446817afbd17273e662c97ee72995ef42640c550b9013fad0761353c7086a272c24088be94769fd16650',
          radix: 16)),
  BigInt.parse(
      '6864797660130609714981900799081393217269435300143305409394463459185543183397655394245057746333217197532963996371363321113864768612440380340372808892707005449',
      radix: 10),
  01,
);

/// [getP521] returns a [EllipticCurve] which implements NIST P-521 (FIPS 186-3, section D.2.5),
/// also known as secp521r1. The CurveParams.Name of this Curve is "P-521".
///
/// Multiple invocations of this function will return the same value, so it can
/// be used for equality checks and switch statements.
///
/// The cryptographic operations do not use constant-time algorithms.
Curve getP521() {
  return _p521;
}

/// [getSecp521r1] is same to [getP521]
Curve getSecp521r1() {
  return _p521;
}
