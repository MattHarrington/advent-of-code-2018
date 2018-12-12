// https://adventofcode.com/2018/day/9

import 'dart:collection';
import 'dart:math';

class Marble<T> extends LinkedListEntry<Marble> {
  T value;

  Marble(this.value);

  @override
  String toString() => '${value}';
}

main() {
  var puzzleInput = "465 players; last marble is worth 71498 points";
  var publishedPartOneAnswer = 383475;
  var publishedPartTwoAnswer = 3148209772;

  var numberOfPlayers = 465;
  var lastMarble = 71498;

  var myPartOneAnswer = playElvishMarbles(numberOfPlayers, lastMarble);
  var myPartTwoAnswer = playElvishMarbles(numberOfPlayers, lastMarble * 100);
  assert(publishedPartOneAnswer == myPartOneAnswer);
  assert(publishedPartTwoAnswer == myPartTwoAnswer);

  print("Part one high score: ${myPartOneAnswer}");
  print("Part two high score: ${myPartTwoAnswer}");
}

int playElvishMarbles(int numberOfPlayers, int lastMarble) {
  const DEBUG = false;
  var dll = LinkedList<Marble>();

  var currentMarble = Marble(0);
  dll.add(currentMarble);

  var score = List<int>.filled(numberOfPlayers, 0);

  for (var i = 1; i <= lastMarble; ++i) {
    var currentPlayerNumber = i % numberOfPlayers;

    if (i % 23 == 0) {
      // Player has scored
      score[currentPlayerNumber] += i;

      Marble marbleToRemove;
      for (var i = 0; i < 7; ++i) {
        marbleToRemove = currentMarble.previous ?? dll.last;
        currentMarble = marbleToRemove;
      }

      Marble marbleClockwise = marbleToRemove.next ?? dll.first;

      score[currentPlayerNumber] += marbleToRemove.value;
      marbleToRemove.unlink();

      currentMarble = marbleClockwise;
      continue; // Don't place new marble
    }

    var nextMarble = Marble(i);
    if (currentMarble.next != null) {
      currentMarble.next.insertAfter(nextMarble);
    } else if (currentMarble.next == null) {
      dll.first.insertAfter(nextMarble);
    }
    currentMarble = nextMarble;

    if (DEBUG) print("${currentPlayerNumber} : ${dll}");
  }
  return score.reduce(max);
}
