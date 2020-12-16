As an exercise this solution is implemented also in other languages. 
Here are ways to run them:

Julia: `julia day_15/bench.jl`

output:
```
276
Trial(44.700 μs)
31916
Trial(2.348 s)
```

Kotlin in JVM:

compile: `C:\Users\racinsky\AppData\Local\JetBrains\Toolbox\apps\IDEA-C\ch-0\203.5981.155\plugins\Kotlin\kotlinc\bin\kotlinc main.kt -include-runtime -d main_kt.jar -jvm-target 1.8`

run: `java -jar main_kt.jar`

output:
```
276
part 1: 5 runs, average millis: 0
31916
part 2: 5 runs, average millis: 4471
```

Kotlin native:

compile: `"C:\Program Files\kotlin-native-windows-1.4.21\bin\kotlinc-native" main.kt -o main_kt.exe`

run: `main_kt.exe`

output:
```
276
5 runs, average millis: 3
31916
5 runs, average millis: 82892
```

Java: `java Main.java`

output:
```
276
part 1: 5 runs, average millis: 0
31916
part 2: 5 runs, average millis: 4143
```

Python: `python main.py`

output:
```
276
part 1: 5 runs, average millis: 0.0005994796752929688
31916
part 2 in numba: 5 runs, average millis: 3.9499990463256838
31916
part 2: 5 runs, average millis: 12.827667427062988
```