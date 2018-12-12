// https://adventofcode.com/2018/day/3
import "dart:io";

main() {
  List<String> claims = File("day_3_input.txt").readAsLinesSync();
  assert(claims.length == 1293);
  // Sample claim: #13 @ 834,885: 26x14

  // Create a multi-dimensional "array" in Dart:
  // https://www.programming-idioms.org/idiom/26/create-a-2-dimensional-array/631/dart
  const int m = 1000;
  const int n = 1000;
  var fabric = new List.generate(m, (_) => new List(n));

  // Part 1
  // "How many square inches of fabric are within two or more claims?"

  int overlappedSquares = 0;  // Count of overlapped squares, used in part 1.

  // Initially a list of nulls.  Value at (claimId - 1) set
  // to true if that claimId overlaps another claim.  Element
  // which remains null corresponds to claimId which doesn't
  // overlap others.  Used in part 2.
  List<bool> overlappedClaims = List<bool>(claims.length);

  for (var claim in claims) {
    List<String> splitClaim = claim.split(" ");
    String claimId = splitClaim[0].substring(1);

    String origin = splitClaim[2].substring(0, splitClaim[2].length - 1);
    List<String> splitOrigin = origin.split(",");
    int x = int.parse(splitOrigin[0]);
    int y = int.parse(splitOrigin[1]);

    String size = splitClaim[3].substring(0, splitClaim[3].length);
    List<String> splitSize = size.split("x");
    int width = int.parse(splitSize[0]);
    int height = int.parse(splitSize[1]);

    for (var h = 0; h < height; ++h) {
      for (var w = 0; w < width; ++w) {
        if (fabric[x + w][y + h] == null) {
          // Square is unclaimed. Mark with claimId.
          fabric[x + w][y + h] = claimId;
        } else if (fabric[x + w][y + h] == "X") {
          // Already marked with X. Don't increment count, but
          // mark claimId as one which overlaps others.
          overlappedClaims[int.parse(claimId) - 1] = true;
        } else {
          // Mark both claimIds as overlapping, mark square with an X,
          // and increment overlappedSquares count.
          String originalClaim = fabric[x + w][y + h];
          overlappedClaims[int.parse(originalClaim) - 1] = true;
          fabric[x + w][y + h] = "X";
          overlappedClaims[int.parse(claimId) - 1] = true;
          ++overlappedSquares;
        }
      }
    }
  }
  print("Number of square inches with multiple claims: ${overlappedSquares}");

  // Part 2
  // "What is the ID of the only claim that doesn't overlap?"

  for (var i = 0; i < overlappedClaims.length; ++i) {
    if (overlappedClaims[i] == null) {
      print("Single claim which doesn't overlap with others: ${i + 1}");
    }
  }
}
