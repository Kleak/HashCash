// Copyright (c) 2015, Kevin Segaud. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:math";

import "package:crypto/crypto.dart";

class HashCash {
  static String _salt(int length) {
    String _ascii_letters =
        "abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ+/=";
    Random rand = new Random();
    String sb = "";
    for (int i = 0; i < length; i++) {
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
          sha256.convert("$challenge$hex_counter".codeUnits).toString();
      if (digest.startsWith(zeros)) {
        return hex_counter;
      }
      counter++;
    }
  }

  /**
   *  Mint a new hashcash stamp for [resource] with [bits] of collision
   *  20 bits of collision is the default.
   *  [extension] lets you add your own extensions to a minted stamp.
   *  Specify an extension as a string of form 'name1=2,3;name2;name3=var1=2,2,val'
   *  FWIW, urllib.urlencode(dct).replace('&',';') comes close to the
   *  hashcash extension format.
   *  [saltchars] specifies the length of the salt used; this version defaults
   *  16 chars, rather than the C version's 16 chars.  This still provides about
   *  17 million salts per resource, per timestamp, before birthday paradox
   *  collisions occur.  Really paranoid users can use a larger salt though.
   *  [stamp_seconds] lets you add the option time elements to the datestamp.
   *  If you want more than just day, you get all the way down to seconds,
   *  even though the spec also allows hours/minutes without seconds.
   */
  static String mint(String resource,
      {int bits: 20,
      DateTime now: null,
      String extension: '',
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
    challenge = "$ver:$bits:$ts:$resource:$extension:${_salt(saltchars)}:";
    return "$challenge${_mint(challenge, bits)}";
  }

  /**
   *  Check whether a [stamp] is valid
   *  Optionally, the [stamp] may be checked for a specific resource, and/or
   *  it may require a minimum bit value, and/or it may be checked for
   *  expiration, and/or it may be checked for double spending.
   *  If [check_expiration] is specified, it should contain the number of
   *  seconds old a date field may be.  Indicating days might be easier in
   *  many cases, e.g.
   */
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
        String digest = sha256.convert(stamp.codeUnits).toString();
        return digest.startsWith(("0" * hex_digits));
      } else {
        print("Malformed version 1 hashcash stamp!\n");
      }
    }
    print("Unknown hashcash version\n");
    return false;
  }
}
