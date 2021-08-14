import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../core/error/failure.dart';
import '../../core/usecases/usecase.dart';
import '../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const SERVER_FAILURE_MESSAGE = 'Server Failure';
const CACHE_FAILURE_MESSAGE = 'Cache Failure';
const INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required GetConcreteNumberTrivia concrete,
    required GetRandomNumberTrivia random,
    required this.inputConverter,
  }) :assert(concrete != null),
      assert(random != null),
      assert(inputConverter != null),
      getConcreteNumberTrivia = concrete,
      getRandomNumberTrivia = random,
      super(Empty());

  // NumberTriviaState get initialState => Empty();

  @override
  Stream<NumberTriviaState> mapEventToState(
    NumberTriviaEvent event,
  ) async* {
    if (event is InitialEvent) {
      yield Empty();
    } else if (event is GetTriviaForConcreteNumber) {
      final inputEither =
          inputConverter.stringToUnsignedInteger(event.numberString);

      yield* inputEither.fold((failure) async* {
        yield Error(message: INVALID_INPUT_FAILURE_MESSAGE);
      }, (number) async* {
        yield Loading();
        final failureOrTrivia = await getConcreteNumberTrivia(Params(number: number));
        yield* _eitherErrorOrTrivia(failureOrTrivia);
      });
    } else if (event is GetTriviaForRandomNumber) {
        yield Loading();
        final failureOrTrivia = await getRandomNumberTrivia(NoParams());
        yield* _eitherErrorOrTrivia(failureOrTrivia);
    }
  }

  Stream<NumberTriviaState> _eitherErrorOrTrivia(Either<Failure, NumberTrivia> failureOrTrivia) async* {
    yield failureOrTrivia.fold((failure) => Error(message: _getFailureMessage(failure)),
        (trivia) => Loaded(trivia: trivia));
  }

  String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
