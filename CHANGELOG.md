## 0.4.0

- **SECURITY**: `scalarMul` now uses a Montgomery ladder (one addition and one
  doubling per scalar bit, exchanged with a branch-free conditional swap) so the
  execution shape no longer depends on secret scalar bits. Dart `BigInt`
  arithmetic itself remains variable-time.
- **SECURITY**: `compressedHexToPublicKey` computes the modular square root with
  Tonelli–Shanks, fixing decoding for curves with p ≡ 1 (mod 4)
  (secp224r1/secp224k1), and validates `x < p` and the recovered root.
- Fix `generatePrivateKey`: remove a leftover test-only byte mutation and
  zero-pad the range-check reconstruction.
- Correct documentation that incorrectly claimed constant-time operations.

## 0.3.12

- **SECURITY FIX**: Add point validation to prevent invalid elliptic curve points from being used in ECDH
  - `PublicKey` constructors now validate that points are on the curve
  - `computeSecret()` validates public key points before ECDH computation
  - Added `ErrPointNotOnCurve` exception for invalid points
  - Prevents potential security vulnerabilities from malformed or malicious public keys

## 0.3.11

- fix EllipticException equality operator warn
- improve scalaMul

## 0.3.10

- Add the PEM example to README

## 0.3.9

- Change sdk to ">=2.12.0 <4.0.0"

## 0.3.8

- Support any a(alpha) value in curve

## 0.3.7

- Fix ecdh computeSecret

## 0.3.6

- Fix ecdh

## 0.3.5

- Add EllipticException for better error handling

## 0.3.4

- Fix hex, Enhance hex
- Enhance bigint calc
- Add tests for hex

## 0.3.3

- Fix bug on generating compressed hex

## 0.3.2

- Add ecdh library

## 0.3.1

- Add support to koblitz curves (secp256k1 & secp224k1)
- Pass tests on secp256k1
- Fix bug on loading compressed public key hex

## 0.3.0

- New abstract class curve for secp256k1 etc in https://www.secg.org/sec2-v2.pdf 
- More customizable params for EllipticCurve (maybe can work on k1)
- Add some TODOs

## 0.2.0

- Null-safe
- Fix bugs
- Pass tests (mainly P256)
- Add utils to PublicKey and PrivateKey

## 0.1.0

- Initial version, created by Stagehand
- Having bugs, dont use this version
