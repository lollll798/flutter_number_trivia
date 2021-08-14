import 'package:clean_arch_tdd/features/number_trivia/core/error/failure.dart';
import 'package:clean_arch_tdd/features/number_trivia/core/util/input_converter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  // return integer when string represent unsigned integer
  // return failure when signed integer / others pass in
  // return failure when negative
  group('stringToUnsignedInteger', () {
    test('should return integer when the string represents an unsigned integer',
    () {
      // arrange
      final String string = '123';
      // act
      final result = inputConverter.stringToUnsignedInteger(string);
      // assert
      expect(result, Right(123));
    });

    test('should return a failure when the string is not an unsigned integer',
    () {
      // arrange
      final String string = '1.0';
      // act
      final result = inputConverter.stringToUnsignedInteger(string);
      // assert
      expect(result, Left(InvalidInputFailure()));
    });

    test('should return a failure when the string is a negative integer',
    () {
      // arrange
      final String string = '-12';
      // act
      final result = inputConverter.stringToUnsignedInteger(string);
      // assert
      expect(result, Left(InvalidInputFailure()));
    });
  });
}
