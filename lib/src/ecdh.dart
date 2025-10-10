import 'publickey.dart';
import 'privatekey.dart';
import 'err.dart';

List<int> computeSecret(PrivateKey selfPriv, PublicKey otherPub) {
  assert(selfPriv.curve == otherPub.curve);

  var curve = selfPriv.curve;
  
  // Validate that the public key point is on the curve
  if (!curve.isOnCurve(otherPub)) {
    throw ErrPointNotOnCurve;
  }
  
  var byteLen = (curve.bitSize + 7) >> 3;
  var p = curve.scalarMul(otherPub, selfPriv.bytes);
  var hex = p.X.toRadixString(16).padLeft(byteLen * 2, '0');
  return List<int>.generate(
      byteLen, (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16));
}

String computeSecretHex(PrivateKey selfPriv, PublicKey otherPub) {
  var sec = computeSecret(selfPriv, otherPub);
  return List<String>.generate(
          sec.length, (index) => sec[index].toRadixString(16).padLeft(2, '0'))
      .join();
}
