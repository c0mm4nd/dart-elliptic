import 'package:elliptic/elliptic.dart';
import 'package:elliptic/ecdh.dart';

void main() {
  // use elliptic curves 
  var ec = getP256();
  var priv = ec.generatePrivateKey();
  var pub = priv.publicKey;
  print('privateKey: 0x$priv');
  print('publicKey: 0x$pub');

  // use ecdh
  var privateAlice = ec.generatePrivateKey();
  var publicAlice = privateAlice.publicKey;
  var privateBob = ec.generatePrivateKey();
  var publicBob = privateAlice.publicKey;
  var secretAlice = computeSecretHex(privateAlice, publicBob);
  var secretBob = computeSecretHex(privateBob, publicAlice);
  print('secretAlice: 0x$secretAlice');
  print('secretBob: 0x$secretBob');
}
