//import java.io.File
//import java.util.stream.IntStream.range
import kotlin.system.measureTimeMillis

//since I can't figure out reasonably simple way to read file in kotlin native, I'll hardcode the input instead
//val raw_data = File("C:\\Projects\\others\\advent_of_code_2020\\day_15\\input.txt").readLines().first()
val raw_data = "0,13,16,17,1,10,6"
fun process_data(): Array<Int> = raw_data.split(',').map { it.toInt() }.toTypedArray()
fun play_game(data: Array<Int>, n_turns: Int): Int {
    val lastOccur = data.dropLast(1).mapIndexed { i, n -> n to i + 1 }.toMap().toMutableMap()
    var curNumber = data.last()
    (data.size until n_turns).forEach { turn ->
        val nextNumber = turn - (lastOccur[curNumber] ?: turn)
        lastOccur[curNumber] = turn
        curNumber = nextNumber
    }
    return curNumber
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
    val n_tries = 10
    println(part1())
    var time1 = 0L
    //val time1 = measureTimeMillis {
    //    for (i in 1..n_tries) part1()
    //}
    repeat(n_tries) {
        time1 += measureTimeMillis { part1() }
    }
    println("part 1: ${n_tries} runs, average millis: ${time1/n_tries}")
    println(part2())
    var time1 = 0L
    //val time2 = measureTimeMillis {
    //    for (i in 1..n_tries) part2()
    //}
    repeat(n_tries) {
        time2 += measureTimeMillis { part2() }
    }
    println("part 2: ${n_tries} runs, average millis: ${time2/n_tries}")

}