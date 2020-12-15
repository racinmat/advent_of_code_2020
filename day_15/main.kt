import java.io.File
import java.util.stream.IntStream.range
import kotlin.system.measureTimeMillis

val raw_data = File("C:\\Projects\\others\\advent_of_code_2020\\day_15\\input.txt").readLines().first()
fun process_data(): Array<Int> = raw_data.split(',').map { it.toInt() }.toTypedArray()
fun play_game(data: Array<Int>, n_turns: Int): Int {
    val last_occur = data.dropLast(1).mapIndexed { i, n -> n to i+1 }.toMap().toMutableMap()
    var cur_number = data.last()
    var turn = data.size
    while (turn < n_turns) {
        var next_number = if (last_occur.containsKey(cur_number)) {
            turn - last_occur[cur_number]!!
        } else {
            0
        }
        last_occur[cur_number] = turn
        cur_number = next_number
        turn += 1
    }
    return cur_number
}

fun part1(): Int {
    val data = process_data()
    return play_game(data, 2020)
}

fun part2(): Int {
    val data = process_data()
    return play_game(data, 30_000_000)
}

fun main() {
    println(part1())
    val time1 = measureTimeMillis {
        range(0, 5).forEach{part1()}
    }
    println("5 runs, average millis: ${time1/5}")
    println(part2())
    val time2 = measureTimeMillis {
        range(0, 5).forEach{part2()}
    }
    println("5 runs, average millis: ${time2/5}")

}