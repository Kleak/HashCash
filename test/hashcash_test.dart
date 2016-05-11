// Copyright (c) 2015, Kevin Segaud. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library hashcash_test;

import "dart:io";

import 'package:hashcash/hashcash.dart';
import 'package:test/test.dart';

void main() => defineTests();

void defineTests() {
  group('HashCash', () {
    String stamp = HashCash.mint("segaud.kevin@gmail.com");

    test('bad resource', () {
      expect(HashCash.check(stamp, resource: "test"), false);
    });

    test('good resource', () {
      expect(HashCash.check(stamp, resource: "segaud.kevin@gmail.com"), true);
    });

    test('different bits', () {
      expect(HashCash.check(stamp, bits: 20), true);
    });

    test('same bits', () {
      expect(HashCash.check(stamp, bits: 15), false);
    });

    test('valid expiration', () {
      expect(HashCash.check(stamp, check_expiration: new Duration(hours: 1)),
          true);
    });

    sleep(new Duration(seconds: 10));

    test('bad expiration', () {
      expect(HashCash.check(stamp, check_expiration: new Duration(seconds: 1)),
          false);
    });

    test('another valid expiration', () {
      expect(HashCash.check(stamp, check_expiration: new Duration(minutes: 1)),
          true);
    });
  });
}
