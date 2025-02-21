import 'dart:async';

import 'package:build/build.dart';

/// Generates file with Hello World comment in it
/// _if_ entry point is present in the Dart file.
class HelloWorldBuilder extends Builder {
  @override
  final Map<String, List<String>> buildExtensions;

  HelloWorldBuilder({
    required this.buildExtensions,
  });

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final libraryElement = await buildStep.inputLibrary;
    if (libraryElement.entryPoint != null) {
      final outputId = buildStep.allowedOutputs.first;
      await buildStep.writeAsString(outputId, '// Hello world!');
    }
  }
}
