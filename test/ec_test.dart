import 'package:elliptic/ecdh.dart';
import 'package:elliptic/elliptic.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    late EllipticCurve ec;

    setUp(() {
      ec = getP256();
    });

    test('Base Test', () {
      print('BitSize ${ec.bitSize}, ByteSize ${(ec.bitSize + 7) >> 3}');
      var priv = ec.generatePrivateKey();
      var _ = priv.publicKey;
    });

    test('Test Keys', () {
      var priv1 = PrivateKey.fromBytes(ec, [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25,
        26,
        27,
        28,
        29,
        30,
        31
      ]);
      var priv2 = PrivateKey.fromHex(ec,
          '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f');
      var priv3 = PrivateKey.fromHex(
          ec, '102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f');
      print(priv1);
      print(priv2);
      expect(priv2, equals(priv1));
      expect(priv3, equals(priv2));
    });

    test('Test Curve', () {
      // openssl ecparam -genkey -name secp256r1 -out k.pem
      // openssl ec -in k.pem -noout -text
      var priv1 = PrivateKey.fromHex(ec,
          '944292792746dccb6d2a2831895c67397a90bee5f1b585c011fb59e7843df012');
      expect(
          priv1.publicKey.toString(),
          equals(
              '043e7159ab4b8f9fa89e1de94687e35839853381043eb9ff13eafd97d2e3af9c92a2056e50a43bc6c2bb90e75a1a5328119d874e18b0f21fc1491a63928ecae82b'));
      var priv2 = PrivateKey.fromHex(ec,
          'e02df4485df99eb1a7efa361c11607936f25e458a4351643e384ecc9653152ae');
      expect(
          priv2.publicKey.toString(),
          equals(
              '04b4be528c581533c2d4de14cfeb8fa5a30cf3d716d674b1be3e0f3a0e4f63e0476ae1a481af6b2d3fc3180b4ded3a538cdb63dc2fba64225b49070f46b49a0992'));
      var priv3 = PrivateKey.fromHex(ec,
          'acdab4a95e2cc2fe90df2749404536c03b44941d4116dc59b40356de19088dc2');
      expect(
          priv3.publicKey.toString(),
          equals(
              '048fe605cc744b71bfba25bb69acc4c29a1a4a8c758d8262dc9bcf3472ce0f50c532e2e4461fc1b8cc61b5f705962aad28300246592e507d2778d3ca2eac78e1fb'));

      var ec384 = getP384();
      var priv4 = PrivateKey.fromHex(ec384,
          '578caf3cf7503af18602aeefe978ad8913fb8802f096ec96cc156c6b3e58854afb90e847c73a63119d2ba4772c033b5f');
      expect(
          priv4.publicKey.toString(),
          equals(
              '044b71543c13337f5ab1bcf7c0206d82d8e2219420da960ee708e61e7bfc486bb8cb414ac0047bb559eed60fceae83aa249e16b043c02ef543bd8ebfffa221204a20f27713249a45e11e65469b4ce0154523f20f13bd080829a7aee17d6cb07fc6'));
    });

    test('Preasure Test', () {
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 10000; i++) {
        var priv = ec.generatePrivateKey();
        var pub = priv.publicKey;

        expect(ec.isOnCurve(pub), isTrue);
      }
      print('gen key & check executed in ${stopwatch.elapsed}');
    });

    test('Test _doubleJacobian', () {
      // var p1 = JacobianPoint(BigInt.zero, BigInt.one, BigInt.two);
      var p1 = AffinePoint.fromXY(BigInt.zero, BigInt.one);
      var p2 = ec.dou(p1);
      expect(
          p2.X,
          equals(BigInt.parse(
              '28948022302589062190674361737351893382521535853822578548883407827216774463490',
              radix: 10)));
      expect(
          p2.Y,
          equals(BigInt.parse(
              '43422033453883593286011542606027840073782303780733867823325111740825161695234',
              radix: 10)));

      var p3 = AffinePoint.fromXY(BigInt.one, BigInt.two);
      var p4 = ec.dou(p3);
      print(p3.X);
      expect(
          p4.X,
          equals(BigInt.parse(
              '115792089210356248762697446949407573530086143415290314195533631308867097853949',
              radix: 10)));

      expect(
          p4.Y,
          equals(BigInt.parse(
              '115792089210356248762697446949407573530086143415290314195533631308867097853949',
              radix: 10)));
    });

    test('Test _addJacobian', () {
      var p1 = AffinePoint.fromXY(BigInt.one, BigInt.two);
      var p2 = AffinePoint.fromXY(BigInt.two, BigInt.zero);
      var p3 = ec.add(p1, p2);
      expect(p3.X, equals(BigInt.one));
      expect(
          p3.Y,
          equals(BigInt.parse(
              '115792089210356248762697446949407573530086143415290314195533631308867097853949',
              radix: 10)));
    });

    test('Test hex', () {
      var priv3 = PrivateKey.fromHex(ec,
          'acdab4a95e2cc2fe90df2749404536c03b44941d4116dc59b40356de19088dc2');
      expect(
          priv3.publicKey.toString(),
          equals(
              '048fe605cc744b71bfba25bb69acc4c29a1a4a8c758d8262dc9bcf3472ce0f50c532e2e4461fc1b8cc61b5f705962aad28300246592e507d2778d3ca2eac78e1fb'));

      expect(
          PublicKey.fromHex(ec,
              '048fe605cc744b71bfba25bb69acc4c29a1a4a8c758d8262dc9bcf3472ce0f50c532e2e4461fc1b8cc61b5f705962aad28300246592e507d2778d3ca2eac78e1fb'),
          equals(priv3.publicKey));
    });

    test('Test S-256', () {
      var testVectors = [
        [
          'c37c299bb7f5ffd8d9329d052983342a8c3234ff3b3fa32a292187341f7146d7',
          '03a12b6218425127f186011ff4c203b8d6ea651877c46f12484b2eda492596484f'
        ],
        [
          '52d62cfcf7062af53f7bec124fe9285eaa8a8963411ba613b7432be73565b6b3',
          '0449aedf74e8f87811761cf3d5fa8f8eaa42b4c657efc986939229a898b3ee27a000f9a247290fb5716c2db17dc193fd4e3f7b36a9947b477c6f0769c15fb8bf79'
        ],
        [
          '0df8d8c6a2bb48af1be87d8403afc15917962898a4fad2b2584276f6adcf7ced',
          '044436b31b9d663d2bb7d6d6e56678f81ed0db65ee74c123ef238b1678399f77e42985555da48e7a80198a5aec11c369ce7b63a759a492ac4315dbf083e6668ce6'
        ],
        [
          '8db69356f772b318c523bbcaa5bddfeddae118ee6aca574e7d2e4332e35fc238',
          '0247d3faa09ce8c4bd46c9b89a680d5b1064bf2bcd321a47358c02e9527c2387e6'
        ]
      ];

      var curve = getSecp256k1();
      for (var vec in testVectors) {
        var priv = PrivateKey.fromHex(curve, vec[0]);
        var pub1 = priv.publicKey;
        var pub2 = PublicKey.fromHex(curve, vec[1]);
        print(pub1);
        print(pub2);
        expect(curve.isOnCurve(pub1), true);
        expect(pub1, pub2);
        expect(
            vec[1] == pub1.toCompressedHex() || vec[1] == pub1.toHex(), isTrue);
      }
    });

    test('Test ECDH 256', () {
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 10000; i++) {
        var ec = getP256();
        var privA = ec.generatePrivateKey();
        var privB = ec.generatePrivateKey();
        var pubA = ec.privateToPublicKey(privA);
        var pubB = ec.privateToPublicKey(privB);

        expect(computeSecret(privA, pubB).toString(),
            equals(computeSecret(privB, pubA).toString()));
      }
      print('gen keys & check ecdh 256 executed in ${stopwatch.elapsed}');
    });

    test('Test ECDH 521', () {
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        var ec = getP521();
        var privA = ec.generatePrivateKey();
        var privB = ec.generatePrivateKey();
        var pubA = ec.privateToPublicKey(privA);
        var pubB = ec.privateToPublicKey(privB);

        expect(computeSecret(privA, pubB).toString(),
            equals(computeSecret(privB, pubA).toString()));
      }
      print('gen keys & check ecdh 521 executed in ${stopwatch.elapsed}');
    });
  });
}
