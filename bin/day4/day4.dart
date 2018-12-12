// https://adventofcode.com/2018/day/4
import 'dart:io';
import 'dart:math';

main() {
  List<String> guardRecords = File("day_4_input.txt").readAsLinesSync();
  assert(guardRecords.length == 1110);

  // Sort input

  guardRecords.sort((a, b) {
    a = a.split("]")[0].substring(1);
    b = b.split("]")[0].substring(1);
    var firstDate = DateTime.parse(a);
    var secondDate = DateTime.parse(b);
    return firstDate.compareTo(secondDate);
  });

  // Variables to remember data through each iteration
  String guardId;
  DateTime fallAsleepTime;
  DateTime wakeUpTime;

  // Map of guardId to a map of [minute to tally].  Minutes are 0 - 59.
  // Tally is how many times guardId was asleep during that minute.
  var guardSleepMap = Map<String, Map<int, int>>();

  // Build guardSleepMap
  for (var guardRecord in guardRecords) {
    // Split record
    // If contains "Guard", remember the guard ID
    // Measure duration between falling asleep and waking up
    // Store in map with key = guardId

    var guardRecordSplit = guardRecord.split("]");
    if (guardRecordSplit[1].contains("Guard")) {
      guardId = guardRecordSplit[1].trim().split(" ")[1];
    } else if (guardRecordSplit[1].contains("falls asleep")) {
      fallAsleepTime = DateTime.parse(guardRecordSplit[0].substring(1));
    } else if (guardRecordSplit[1].contains("wakes up")) {
      // This condition only met after "falls asleep".  Do bulk
      // of the work here.

      wakeUpTime = DateTime.parse(guardRecordSplit[0].substring(1));

      Map<int, int> minuteTally = Map<int, int>(); // Minute number -> tally
      if (guardSleepMap[guardId] != null) {
        // Get previous tally map if it exists
        minuteTally = guardSleepMap[guardId];
      }
      // Loop through 60 minutes
      for (int i = 0; i < 60; ++i) {
        minuteTally.putIfAbsent(i, () => 0);
        if (i >= fallAsleepTime.minute && i <= wakeUpTime.minute - 1)
          // "Note that guards count as asleep on the minute they fall asleep,
          // and they count as awake on the minute they wake up. For example,
          // because Guard #10 wakes up at 00:25 on 1518-11-01, minute 25
          // is marked as awake."
          minuteTally[i]++;
      }

      guardSleepMap[guardId] = minuteTally;
    }
  }

  // Now find longest duration and minute most likely to be asleep
  var sleepiestGuardId = "";
  int sleepiestMinute = -100;
  int largestTally = -100;
  var guardWithSleepiestMinute = "";
  int mostMinutesSlept = -100;

  guardSleepMap.forEach((id, minuteTallyMap) {
    int minutesSlept = 0;
    minuteTallyMap.forEach((minuteNumber, tally) {
      minutesSlept += tally;
      if (tally > largestTally) {
        largestTally = tally;
        sleepiestMinute = minuteNumber;
        guardWithSleepiestMinute = id;
      }
    });
    if (minutesSlept > mostMinutesSlept) {
      mostMinutesSlept = minutesSlept;
      sleepiestGuardId = id;
    }
  });

  print("Part 1 ...");
  print("Sleepiest guard ID: ${sleepiestGuardId}");
  var minutesMostAsleep = guardSleepMap[sleepiestGuardId].values.reduce(max);
  print("Minutes guard ${sleepiestGuardId} is "
      "most asleep: ${minutesMostAsleep}");
  print("Which corresponds to minute: "
      "${guardSleepMap[sleepiestGuardId].keys.firstWhere((k) => guardSleepMap[sleepiestGuardId][k] == minutesMostAsleep)}");
  print("\n");

  print("Part 2 ...");
  print("Guard with sleepiest minute: ${guardWithSleepiestMinute}");
  print("Sleepiest minute: ${sleepiestMinute}");
  print("That guard ID multiplied by sleepiest minute = "
      "${int.parse(guardWithSleepiestMinute.substring(1)) * sleepiestMinute}");
}
