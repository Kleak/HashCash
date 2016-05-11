// Copyright (c) 2015, Kevin Segaud. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "package:hashcash/hashcash.dart";

main() {
  String stamp = HashCash.mint("segaud.kevin@gmail.com", bits: 15);
  print(stamp);
}
