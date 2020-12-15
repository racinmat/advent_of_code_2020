As an exercise this solution is implemented also in other languages. 
Here are ways to run them:

Kotlin in JVM:
compile: `C:\Users\racinsky\AppData\Local\JetBrains\Toolbox\apps\IDEA-C\ch-0\203.5981.155\plugins\Kotlin\kotlinc\bin\kotlinc main.kt -include-runtime -d main_kt.jar -jvm-target 1.8`
run: `java -jar main_kt.jar`
output:
276
5 runs, average millis: 0
31916
5 runs, average millis: 4936

Kotlin native:
compile: `"C:\Program Files\kotlin-native-windows-1.4.21\bin\kotlinc-native" main.kt -o main_kt.exe`
can't compile it now, fuck
run: 

Java: `java Main.java`
output:
276
5 runs, average millis: 0
31916
5 runs, average millis: 4317