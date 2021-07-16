import 'base.dart';
import 'elliptic.dart';

/// P curves

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

/// S curves

late EllipticCurve _s224 = EllipticCurve(
  'secp224k1',
  224,
  BigInt.parse('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFE56D',
      radix: 16), // p
  BigInt.zero, // a
  BigInt.from(5), // b
  BigInt.zero, // S
  AffinePoint.fromXY(
      BigInt.parse('A1455B334DF099DF30FC28A169A467E9E47075A90F7E650EB6B7A45C',
          radix: 16),
      BigInt.parse('7E089FED7FBA344282CAFBD6F7E319F7C0B0BD59E2CA4BDB556D61A5',
          radix: 16)), // G
  BigInt.parse('010000000000000000000000000001DCE8D2EC6184CAF0A971769FB1F7',
      radix: 16), // n
  01, // h
);

/// [getS224] returns a [EllipticCurve] which implements S-224, aka secp224k1
///
/// The cryptographic operations are implemented using constant-time algorithms.
Curve getS224() {
  return _s224;
}

/// [getSecp224k1] is same to [getS224]
Curve getSecp224k1() {
  return _s224;
}

late EllipticCurve _s256 = EllipticCurve(
  'secp256k1',
  256,
  BigInt.parse(
      'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
      radix: 16), // p
  BigInt.zero, // a
  BigInt.from(7), // b
  BigInt.zero, // S
  AffinePoint.fromXY(
      BigInt.parse(
          '79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798',
          radix: 16),
      BigInt.parse(
          '483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',
          radix: 16)), // G
  BigInt.parse(
      'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
      radix: 16), // n
  01, // h
);

/// [getS256] returns a [EllipticCurve] which implements S-256, aka secp256k1
///
/// The cryptographic operations are implemented using constant-time algorithms.
Curve getS256() {
  return _s256;
}

/// [getSecp256k1] is same to [getS256]
Curve getSecp256k1() {
  return _s256;
}

// TODO: apply this for S-curves for optimization
	// Next 6 constants are from Hal Finney's bitcointalk.org post:
	// https://bitcointalk.org/index.php?topic=3238.msg45565#msg45565
	// May he rest in peace.