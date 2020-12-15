import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.HashMap;

import static java.util.stream.IntStream.range;

public class Main {
    public static int play_game(int[] data, int n_turns) {
        var last_occur = new HashMap<Integer, Integer>();
        for (int i = 0; i < data.length-1; i++) {
            last_occur.put(data[i], i+1);
        }
        var cur_number = data[data.length-1];
        var turn = data.length;
        var next_number = 0;
        while (turn < n_turns) {
            if (last_occur.containsKey(cur_number)) {
                next_number = turn - last_occur.get(cur_number);
            } else {
                next_number = 0;
            }
            last_occur.put(cur_number, turn);
            cur_number = next_number;
            turn += 1;
        }
        return cur_number;
    }

    public static int part1(String raw_data) {
        var data = process_data(raw_data);
        return play_game(data, 2020);
    }

    public static int part2(String raw_data) {
        var data = process_data(raw_data);
        return play_game(data, 30_000_000);
    }
    public static int[] process_data(String raw_data) {
        return Arrays.stream(raw_data.split(",")).mapToInt(Integer::parseInt).toArray();
    }
    public static void main(String[] args) throws IOException {
        var raw_data = Files.readString(Path.of("C:\\Projects\\others\\advent_of_code_2020\\day_15\\input.txt"));
        System.out.println(part1(raw_data));

        long startTime1 = System.currentTimeMillis();
        range(0, 5).forEach(i->part1(raw_data));
        long endTime1 = System.currentTimeMillis();
        System.out.println("5 runs, average millis: " + (endTime1 - startTime1)/5);

        System.out.println(part2(raw_data));
        long startTime2 = System.currentTimeMillis();
        range(0, 5).forEach(i->part2(raw_data));
        long endTime2 = System.currentTimeMillis();
        System.out.println("5 runs, average millis: " + (endTime2 - startTime2)/5);
    }
}
