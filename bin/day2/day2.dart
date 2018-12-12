// https://adventofcode.com/2018/day/2

import "dart:io";

main() {
  List<String> boxIds = File("day_2_input.txt").readAsLinesSync();
  assert(boxIds.length == 250);

  // Part 1
  // "[Count] the number that have an ID containing exactly two of any
  // letter and then separately counting those with exactly three of any
  // letter. You can multiply those two counts together to get a rudimentary
  // checksum..."

  var boxIdMaps = List<Map<String, int>>();
  for (var boxId in boxIds) {
    var boxMap = Map<String, int>();

    // Dart Strings do not appear to be Iterables,
    // so can't use "for ... in" to loop through characters.
    for (var i = 0; i < boxId.length; i++) {
      // https://www.dartlang.org/guides/libraries/library-tour#collections
      // "To check whether a map contains a key, use containsKey(). Because
      // map values can be null, you cannot rely on simply getting the value
      // for the key and checking for null to determine the existence of a key."
      if (!boxMap.containsKey(boxId[i])) {
        boxMap[boxId[i]] = 1;
      } else {
        ++boxMap[boxId[i]];
      }
    }

    boxIdMaps.add(boxMap);
  }

  int twoLetterBoxCount = 0;
  int threeLetterBoxCount = 0;

  for (var boxIdMap in boxIdMaps) {
    if (boxIdMap.values.contains(2)) {
      twoLetterBoxCount++;
    }
    if (boxIdMap.values.contains(3)) {
      threeLetterBoxCount++;
    }
  }

  print("Checksum of ID list: ${twoLetterBoxCount * threeLetterBoxCount}");

  // Part 2
  // "The boxes will have IDs which differ by exactly one character at the
  // same position in both strings."
  // Create substrings by eliminating character at one position.  Then look
  // for matches.  If no match, eliminate character at next position.

  for (int i = 0; i < boxIds.first.length; ++i) {
    var idSubstringMap = Map<String, int>();
    for (var boxId in boxIds) {
      var key = boxId.substring(0, i) + boxId.substring(i + 1);
      if (!idSubstringMap.containsKey(key)) {
        idSubstringMap[key] = 1;
      } else {
        ++idSubstringMap[key];
      }
    }
    idSubstringMap.forEach((k, v) {
      if (v == 2) {
        print("Common letters between 2 correct boxes: ${k}");
        // break;  // Does not work here for some reason. Since match
        // has been found, no need to continue outer for loop.  NB: also
        // in forEach here, which might cause the confusion.
      }
    });
  }
}
