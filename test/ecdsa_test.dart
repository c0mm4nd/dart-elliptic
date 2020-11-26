import 'package:elliptic/elliptic.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    EllipticCurve ec;

    setUp(() {
      ec = getP256();
    });

    test('First Test', () {
      var priv = ec.generatePrivateKey();
      var _ = priv.publicKey;
    });
  });
}
