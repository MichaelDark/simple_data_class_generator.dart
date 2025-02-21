import 'package:build/build.dart';
import 'package:simple_data_class_generator/src/builders/hello_world_builder.dart';

Builder helloWorldBuilder(BuilderOptions options) {
  return HelloWorldBuilder(
    buildExtensions: const {
      ".dart": [".hw.dart"],
    },
  );
}
