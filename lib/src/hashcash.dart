// Copyright (c) 2015, Kevin Segaud. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:math";

import "package:crypto/crypto.dart";

class HashCash {
  static String _salt(int l) {
    String _ascii_letters =
        "abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ+/=";
    Random rand = new Random();
    String sb = "";
    for (int i = 0; i < l; i++) {
      sb = "$sb${_ascii_letters[rand.nextInt(_ascii_letters.length)]}";
    }
    return sb;
  }

  static String _mint(String challenge, int bits) {
    int counter = 0;
    int hex_digits = (bits / 4.0).ceil();
    String zeros = "0" * hex_digits;
    while (true) {
      String hex_counter = counter.toRadixString(16);
      String digest =
          sha1.convert("$challenge$hex_counter".codeUnits).toString();
      if (digest.startsWith(zeros)) {
        return hex_counter;
      }
      counter++;
    }
  }

  static String mint(String resource,
      {int bits: 20,
      DateTime now: null,
      String ext: '',
      int saltchars: 16,
      bool stamp_seconds: true}) {
    String ts = "";
    String challenge;
    String ver = "1";
    String iso_now = now == null
        ? new DateTime.now().toIso8601String()
        : now.toIso8601String();
    iso_now = iso_now.replaceAll("-", "");
    iso_now = iso_now.replaceAll(":", "");
    List<String> date_time = iso_now.split("T");
    ts = date_time[0].substring(2, date_time[0].length);
    if (stamp_seconds) {
      ts = "$ts${date_time[1].substring(0, 6)}";
    }
    challenge = "$ver:$bits:$ts:$resource:$ext:${_salt(saltchars)}:";
    return "$challenge${_mint(challenge, bits)}";
  }

  static bool check(String stamp,
      {String resource: null, int bits: 20, Duration check_expiration: null}) {
    if (stamp == null) {
      return false;
    }
    if (stamp.startsWith("1:")) {
      List<String> data = stamp.split(":");
      if (data.length == 7) {
        int claim = int.parse(data[1], onError: (e) => -1);
        if (claim == -1) {
          return false;
        }
        int day = int.parse(data[2].substring(4, 6), onError: (e) => -1);
        int month = int.parse(data[2].substring(2, 4), onError: (e) => -1);
        int year = int.parse(data[2].substring(0, 2), onError: (e) => -1);
        if (day == -1 || month == -1 || year == -1) {
          return false;
        }
        int hour;
        int minute;
        if (data[2].length >= 10) {
          hour = int.parse(data[2].substring(6, 8), onError: (e) => -1);
          minute = int.parse(data[2].substring(8, 10), onError: (e) => -1);
          if (hour == -1 || minute == -1) {
            return false;
          }
        }
        DateTime dt;
        if (hour != null && minute != null) {
          dt = new DateTime(year + 2000, month, day, hour, minute);
        } else {
          dt = new DateTime(year + 2000, month, day);
        }
        if (resource != null && resource != data[3]) {
          return false;
        } else if (bits != null && bits != claim) {
          return false;
        } else if (check_expiration != null) {
          DateTime good_until = dt.add(check_expiration);
          DateTime now = new DateTime.now();
          if (now.isAfter(good_until)) {
            return false;
          }
        }
        int hex_digits = (claim / 4).floor();
        String digest = sha1.convert(stamp.codeUnits).toString();
        return digest.startsWith(("0" * hex_digits));
      } else {
        print("Malformed version 1 hashcash stamp!\n");
      }
    }
    print("Unknown hashcash version\n");
    return false;
  }
}
