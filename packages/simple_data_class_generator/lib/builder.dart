import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:simple_data_class_generator/src/builders/hello_world_builder.dart';
import 'package:simple_data_class_generator/src/generators/data_class_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder helloWorldBuilder(BuilderOptions options) {
  return HelloWorldBuilder(
    buildExtensions: const {
      ".dart": [".hw.dart"],
    },
  );
}

Builder dataClassBuilder(BuilderOptions options) {
  return LibraryBuilder(
    DataClassGenerator(),
    formatOutput: (code, version) => DartFormatter(
      pageWidth: 120,
      languageVersion: version,
    ).format(code),
    generatedExtension: '.data_class.dart',
  );
}
