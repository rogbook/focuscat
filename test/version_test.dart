import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:focuscat/screens.dart';

void main() {
  test('앱 정보 화면의 버전이 pubspec 과 같다', () {
    // 한 번 어긋난 적이 있다 — 1.0.1 을 올렸는데 화면은 1.0.0 이었다.
    // 버전을 올릴 때 한쪽만 고치면 여기서 걸린다.
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => l.startsWith('version:'));
    final pubspec = line.split(':')[1].trim().split('+')[0];
    expect(kAppVersion, pubspec);
  });
}
