import 'dart:convert';

import 'package:clean_arch_tdd/features/number_trivia/core/error/exception.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import '../repositories/number_trivia_repository_impl_test.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late NumberTriviaLocalDataSourceImpl numberTriviaLocalDataSource;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    numberTriviaLocalDataSource = NumberTriviaLocalDataSourceImpl(mockSharedPreferences);
  });

  // getLastNumberTrivia
  // return last number
  // cache exception
  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    test(
      'should return NumberTrivia from SharedPreferences when there is one in the cache',
      () async {
        // arrange
        when(mockSharedPreferences.getString(any as dynamic))
            .thenReturn(fixture('trivia_cached.json'));
        // act
        final result = await numberTriviaLocalDataSource.getLastNumberTrivia();
        // assert
        verify(mockSharedPreferences.getString(CACHE_NUMBER_TRIVIA));
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test('should throw a CacheException when there is not a cached value', () {
      // arrange
      when(mockSharedPreferences.getString(any as dynamic)).thenReturn(null as dynamic);
      // act
      final call = numberTriviaLocalDataSource.getLastNumberTrivia;
      // assert
      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  // cacheNumberTrivia
  // store trivia
  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'test trivia');
    
    test('should call SharedPreferences to cache the data', () {
      // act
      numberTriviaLocalDataSource.cacheNumberTrivia(tNumberTriviaModel);
      // assert
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(CACHE_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}