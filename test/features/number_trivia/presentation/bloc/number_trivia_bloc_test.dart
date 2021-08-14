import 'package:clean_arch_tdd/features/number_trivia/core/error/failure.dart';
import 'package:clean_arch_tdd/features/number_trivia/core/usecases/usecase.dart';
import 'package:clean_arch_tdd/features/number_trivia/core/util/input_converter.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_arch_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockRandomNumberTrivia mockRandomNumberTrivia;
  late MockInputConverter mockInputConverter;
  late NumberTriviaBloc bloc;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockRandomNumberTrivia = MockRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  final String tNumberString = '1';
  final int tNumberParsed = 1;
  final NumberTrivia tNumberTrivia =
      NumberTrivia(text: 'Test trivia', number: tNumberParsed);

  void mockInputConverterSuccess() =>
      when(mockInputConverter.stringToUnsignedInteger(any as dynamic))
          .thenReturn(Right(tNumberParsed));

  test('Initial state should be empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    test(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        () async {
      // arrange
      mockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any as dynamic))
          .thenAnswer((_) async => Right(tNumberTrivia));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(
          mockInputConverter.stringToUnsignedInteger(tNumberString));
      // assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid', () {
      // arrange
      when(mockInputConverter.stringToUnsignedInteger(any as dynamic))
          .thenReturn(Left(InvalidInputFailure()));
      bloc.add(InitialEvent());

      // assert later
      final expectedState = [
        Empty(),
        Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream, emitsInOrder(expectedState));

      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the concrete use case', () async {
      // arrange
      mockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any as dynamic))
          .thenAnswer((_) async => Right(tNumberTrivia));

      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any as dynamic));

      // assert
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test('should emit [Loading, Error] when getting data fails', () {
      // arrange
      mockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any as dynamic))
          .thenAnswer((_) async => Left(ServerFailure()));
      bloc.add(InitialEvent());

      // assert later
      final expectedState = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc.stream, emitsInOrder(expectedState));

      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        () {
      // arrange
      mockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any as dynamic))
          .thenAnswer((_) async => Left(CacheFailure()));
      bloc.add(InitialEvent());

      // assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
  });
  
  group('GetTriviaForRandomNumber', () {
    test('should get data from the random use case', () async {
      // arrange
      when(mockRandomNumberTrivia(any as dynamic))
          .thenAnswer((_) async => Right(tNumberTrivia));

      // act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockRandomNumberTrivia(any as dynamic));

      // assert
      verify(mockRandomNumberTrivia(NoParams()));
    });

    test('should emit [Loading, Error] when getting data fails', () {
      // arrange
      when(mockRandomNumberTrivia(any as dynamic))
          .thenAnswer((_) async => Left(ServerFailure()));
      bloc.add(InitialEvent());

      // assert later
      final expectedState = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc.stream, emitsInOrder(expectedState));

      // act
      bloc.add(GetTriviaForRandomNumber());
    });

    test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        () {
      // arrange
      when(mockRandomNumberTrivia(any as dynamic))
          .thenAnswer((_) async => Left(CacheFailure()));
      bloc.add(InitialEvent());

      // assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));

      // act
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
