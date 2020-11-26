import 'package:elliptic/elliptic.dart';

void main() {
  var ec = getP256();
  var priv = ec.generatePrivateKey();
  var pub = priv.publicKey;
  print('privateKey: 0x${priv}');
  print('publicKey: 0x${pub}');
}
