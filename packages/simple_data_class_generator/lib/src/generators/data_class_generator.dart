import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

class DataClassGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
    void log(String message) {
      print('[${buildStep.inputId.path}] $message');
    }

    final classElements = library.allElements.whereType<ClassElement>();
    final abstractClassElements = classElements.where((classElement) => classElement.isAbstract);
    final potentialDataClasses = abstractClassElements.where((e) => e.getDisplayString().endsWith('DataClass'));
    final records = potentialDataClasses.map(
      (e) => (
        className: e.name.substring(0, e.name.length - 'DataClass'.length),
        fields: e.accessors,
      ),
    );

    if (records.isEmpty) {
      return null;
    }
    log('${records.length} data class(es) found');

    final Library generatedLibrary = Library((libraryBuilder) {
      libraryBuilder.body.addAll(records.map(_dataClass));
    });

    final dartEmitter = DartEmitter(
      allocator: Allocator(),
      orderDirectives: true,
      useNullSafetySyntax: true,
    );
    return generatedLibrary.accept(dartEmitter).toString();
  }

  Class _dataClass(({String className, Iterable<PropertyAccessorElement> fields}) record) {
    final (:className, :fields) = record;
    return Class(
      (classBuilder) {
        classBuilder.name = className;
        classBuilder.fields.addAll(fields.map(_field));
        classBuilder.constructors.add(_contructor(fields));
        classBuilder.methods.add(_copyWithMethod(className, fields));
      },
    );
  }

  Field _field(PropertyAccessorElement field) {
    return Field((fieldBuilder) {
      fieldBuilder.name = field.displayName;
      fieldBuilder.type = refer(field.returnType.getDisplayString());
      fieldBuilder.modifier = FieldModifier.final$;
    });
  }

  Constructor _contructor(Iterable<PropertyAccessorElement> fields) {
    return Constructor(
      (constructorBuilder) {
        for (final field in fields) {
          constructorBuilder.constant = true;
          constructorBuilder.optionalParameters.add(
            Parameter(
              (parameterBuilder) {
                parameterBuilder.named = true;
                parameterBuilder.required = true;
                parameterBuilder.name = field.displayName;
                parameterBuilder.toThis = true;
              },
            ),
          );
        }
      },
    );
  }

  Method _copyWithMethod(String className, Iterable<PropertyAccessorElement> fields) {
    return Method(
      (method) {
        method.returns = refer(className);
        method.name = 'copyWith';
        for (final field in fields) {
          method.optionalParameters.add(
            Parameter(
              (parameterBuilder) {
                parameterBuilder.named = true;
                parameterBuilder.required = false;
                parameterBuilder.name = field.displayName;
                parameterBuilder.type = Reference('${field.returnType.getDisplayString()}?');
              },
            ),
          );
        }
        method.body = refer(className)
            .call([], {
              for (final field in fields)
                field.displayName: refer(field.displayName).ifNullThen(
                  refer('this').property(field.displayName),
                ),
            })
            .returned
            .statement;
      },
    );
  }
}
