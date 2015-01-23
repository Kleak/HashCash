// Import BenchmarkBase class.
import 'package:benchmark_harness/benchmark_harness.dart';
import "package:hashcash/hashcash.dart";

// Create a new benchmark by extending BenchmarkBase
class Benchmark extends BenchmarkBase {
  const Benchmark() : super("HashCash.mint");

  static void main() {
    new Benchmark().report();
  }

  // The benchmark code.
  void run() {
    HashCash.mint("segaud.kevin@gmail.com", bits: 15);
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() { }

  // Not measures teardown code executed after the benchark runs.
  void teardown() { }
}

main() {
  // Run TemplateBenchmark
  Benchmark.main();
}