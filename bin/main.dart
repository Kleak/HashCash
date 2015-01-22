// Copyright (c) 2015, Kevin Segaud. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "package:hashcash/hashcash.dart";

main() {
  //  1000 occurence time average 1.289sec 22/011/2015 10Pm

  Stopwatch sw = new Stopwatch();
  int l = 1000;
  sw.start();
  for (int i = 0; i < l; i++) {
    String stamp = HashCash.mint("segaud.kevin@gmail.com", bits: 15);
  }
  sw.stop();
  print(sw.elapsed.inSeconds / l);
}
