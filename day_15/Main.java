import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.HashMap;
import java.util.concurrent.atomic.AtomicLong;
import java.util.function.Consumer;

import static java.util.stream.IntStream.range;

public class Main {
    public static int play_game(int[] data, int n_turns) {
        var last_occur = new HashMap<Integer, Integer>();
        for (int i = 0; i < data.length - 1; i++) {
            last_occur.put(data[i], i + 1);
        }
        var cur_number = data[data.length - 1];
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

    public static long timed_f(Consumer<Integer> c) {
        var startTime = System.currentTimeMillis();
        c.accept(0);
        long endTime = System.currentTimeMillis();
        return endTime - startTime;
    }

    public static void main(String[] args) throws IOException {
        var raw_data = Files.readString(Path.of("C:\\Projects\\others\\advent_of_code_2020\\day_15\\input.txt"));
        System.out.println(part1(raw_data));
        var n_tries = 10;
        AtomicLong t1 = new AtomicLong(0L);
        range(0, n_tries).forEach(i -> t1.addAndGet(timed_f(j -> part1(raw_data))));
        System.out.println("part 1: " + n_tries + " runs, average millis: " + t1.get() / n_tries);

        System.out.println(part2(raw_data));
        AtomicLong t2 = new AtomicLong(0L);
        range(0, n_tries).forEach(i -> t2.addAndGet(timed_f(j -> part2(raw_data))));
        System.out.println("part 2: " + n_tries + " runs, average millis: " + t2.get() / n_tries);
    }
}
