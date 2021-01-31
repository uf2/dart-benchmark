import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:crypto/crypto.dart';

final CHILDREN = Platform.numberOfProcessors;
final POINTS_PER_CHILD = 100000;

void main(List<String> arguments) async {
  print('Doing it the slow (single-process) way...');
  final benchmarkTimer1 = Stopwatch();
  benchmarkTimer1.start();
  for (var i = 0; i < CHILDREN * POINTS_PER_CHILD; i++) {
    someUsefulWork(i);
  }
  benchmarkTimer1.stop();
  print('slow way took: ${benchmarkTimer1.elapsedMicroseconds}');

  print('Doing it the fast (multi-process) way...');
  var ret = CHILDREN;
  final benchmarkTimer2 = Stopwatch();
  benchmarkTimer2.start();
  for (var i = 0; i < CHILDREN; i++) {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(runJob, receivePort.sendPort);
    receivePort.listen((data) {
      --ret;
      isolate.kill(priority: Isolate.immediate);
      if (ret == 0) {
        benchmarkTimer2.stop();
        print('fast way took: ${benchmarkTimer2.elapsedMicroseconds}');
        print(
            '${(benchmarkTimer1.elapsedMicroseconds / benchmarkTimer2.elapsedMicroseconds).toStringAsFixed(2)} faster');
        exit(0);
      }
    });
  }
}

void runJob(SendPort sendPort) {
  for (var i = 0; i < POINTS_PER_CHILD; i++) {
    someUsefulWork(i);
  }
  sendPort.send(null);
}

String someUsefulWork(int i) =>
    sha256.convert(utf8.encode(i.toString())).toString();