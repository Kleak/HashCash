// Copyright (c) 2015, Kevin Segaud. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library hashcash;

import "dart:math";

import "package:crypto/crypto.dart";

part './src/hashcash.dart';

class HashCash {
  static String mint(String resource,
                     {int bits: 20, DateTime now: null, String ext: '',
                       int saltchars: 16, bool stamp_seconds: true})
  => _HashCash.mint(resource, bits: bits, now: now, ext: ext,
      saltchars: saltchars, stamp_seconds: stamp_seconds);

  static bool check(String stamp, {String resource: null, int bits: 20,
    Duration check_expiration: null})
  => _HashCash.check(stamp, resource: resource, bits: bits,
      check_expiration: check_expiration);
}