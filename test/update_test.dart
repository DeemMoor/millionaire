import 'package:flutter_test/flutter_test.dart';
import 'package:millionaire/update/release.dart';

void main() {
  test('isNewer compares X.Y.Z and ignores the build number', () {
    expect(isNewer('2.0.1', '2.0.0'), isTrue);
    expect(isNewer('2.1.0', '2.0.9'), isTrue);
    expect(isNewer('10.0.0', '9.9.9'), isTrue);
    expect(isNewer('2.0.0', '2.0.0'), isFalse);
    expect(isNewer('2.0.0+7', '2.0.0'), isFalse);
    expect(isNewer('1.9.9', '2.0.0'), isFalse);
  });

  test('checksumFor reads sha256sum output', () {
    const listing =
        'ABC123  millionaire-2.0.0-windows-setup.exe\n'
        'def456 *millionaire-2.0.0-linux-x64.tar.gz\n';
    expect(
      checksumFor(listing, 'millionaire-2.0.0-windows-setup.exe'),
      'abc123',
    );
    expect(
      checksumFor(listing, 'millionaire-2.0.0-linux-x64.tar.gz'),
      'def456',
    );
    expect(checksumFor(listing, 'other.exe'), isNull);
  });
}
