// Copyright (c) 2015, Kevin Segaud. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

part of hashcash;

class HashCash {
  static List<String> _ascii_letters = ["a", "b", "c", "d", "e", "f", "g",
                                        "h", "i","j","k", "l", "m", "n", "o",
                                        "p", "q", "r","s", "t","u", "v", "w",
                                        "x", "y", "z"];

  static String mint(String resource,
                     {int bits: 20, DateTime now: null, String ext: '',
                     int saltchars: 16, bool stamp_seconds: true}) {
    StringBuffer ts = new StringBuffer();
    String challenge;
    String ver = "1";
    now = now == null ? new DateTime.now() : now;
    if (stamp_seconds) {
      ts.write(_addZeroBeforeNumber(now.day, 2));
      ts.write(_addZeroBeforeNumber(now.month, 2));
      ts.write(now.year.toString().substring(2, 4));
      ts.write(_addZeroBeforeNumber(now.hour, 2));
      ts.write(_addZeroBeforeNumber(now.minute, 2));
    } else {
      ts.write(_addZeroBeforeNumber(now.day, 2));
      ts.write(_addZeroBeforeNumber(now.month, 2));
      ts.write(now.year.toString().substring(2, 4));
    }
    challenge = "$ver:$bits:$ts:$resource:$ext:${_salt(saltchars)}";
    return "${challenge}:${_mint(challenge, bits)}";
  }

  static String _salt(int l) {
    Random rand = new Random();
    StringBuffer sb = new StringBuffer();
    for (int i = 0; i < l; i++) {
      sb.write(_ascii_letters[rand.nextInt(_ascii_letters.length)]);
    }
    return sb.toString();
  }

  static String _addZeroBeforeNumber(int number, int length) {
    String s_number = number.toString();
    int diff = length - s_number.length;
    if (diff > 0) {
      String zeros = "0" * diff;
      return "$zeros$s_number";
    }
    return s_number;
  }

  static String _mint(String challenge, int bits) {
    int counter = 0;
    int hex_digits = (bits / 4.0).ceil();
    String zeros = "0" * hex_digits;
    SHA1 sha1 = new SHA1();
    while (true) {
      sha1.add("$challenge:${counter.toRadixString(16)}".codeUnits);
      String digest = CryptoUtils.bytesToHex(sha1.close());
      if (digest.substring(0, hex_digits) == zeros) {
        return counter.toRadixString(16);
      }
      counter++;
      sha1 = sha1.newInstance();
    }
  }

  static bool check(String stamp,
                    {String resource: null,
                    int bits: null,
                    Duration check_expiration: null}) {
    if (stamp.startsWith("1:")) {
      List<String> data = stamp.split(":");
      if (data.length == 7) {
        String ver = data[0];
        int claim = int.parse(data[1], onError: (e) => -1);
        String date_time = data[2];
        int day = int.parse(data[2].substring(0, 2), onError: (e) => -1);
        int month = int.parse(data[2].substring(2, 4), onError: (e) => -1);
        int year = int.parse(data[2].substring(4, 6), onError: (e) => -1);
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
        String res = data[3];
        String ext = data[4];
        String rand = data[5];
        String counter = data[6];
        if (resource != null && resource != res) {
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
        SHA1 sha1 = new SHA1();
        sha1.add(stamp.codeUnits);
        String digest = CryptoUtils.bytesToHex(sha1.close());
        return digest.startsWith(("0" * hex_digits));
      } else {
        print("Malformed version 1 hashcash stamp!\n");
      }
    }
    print("Unknown hashcash version\n");
    return false;
  }
}
