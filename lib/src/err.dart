class EllipticException implements Exception {
  late String message;

  EllipticException(this.message);

  @override
  String toString() {
    Object? message = this.message;
    return 'SchnorrException: $message';
  }

  @override
  int get hashCode => message.hashCode;

  @override
  bool operator ==(Object other) =>
      other is EllipticException && message == other.message;
}

var ErrInvalidPublicKeyHexLength =
    EllipticException('publickey hex length is invalid');

var ErrInvalidPublicKeyHexPrefix =
    EllipticException('publickey hex prefix is invalid');

var ErrInvalidPrivateKeyHexLength =
    EllipticException('privatekey hex length is invalid');
