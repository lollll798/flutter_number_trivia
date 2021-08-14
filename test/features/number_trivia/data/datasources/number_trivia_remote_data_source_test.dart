import 'dart:convert';
import 'dart:io';

import 'package:clean_arch_tdd/features/number_trivia/core/error/exception.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttpClient;
  late NumberTriviaRemoteDataSourceImpl numberTriviaRemoteDataSourceImpl;

  setUp(() {
    mockHttpClient = MockHttpClient();
    numberTriviaRemoteDataSourceImpl = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void callNumberTriviaAPI200() {
      when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void callNumberTriviaAPI404() {
      when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  // getTrivia
  // can connect to API
  // return Model if success
  // throw exception if unsuccess

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    
    test('''should preform a GET request on a URL with number 
    being the endpoint and with application/json header''', () {
      // arrange
      callNumberTriviaAPI200();
      // act
      numberTriviaRemoteDataSourceImpl.getConcreteNumberTrivia(tNumber);
      // assert
      verify(mockHttpClient.get('$HOST$tNumber', headers: HEADER));
    });
    
    test('should return NumberTriviaModel when API call is success(200)', () async {
      // arrange
      callNumberTriviaAPI200();
      // act
      final result = await numberTriviaRemoteDataSourceImpl.getConcreteNumberTrivia(tNumber);
      // assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should return ServerException when API call is unsuccess(404 or others)', () async {
      // arrange
      callNumberTriviaAPI404();
      // act
      final call = numberTriviaRemoteDataSourceImpl.getConcreteNumberTrivia;
      // assert
      expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    
    test('''should preform a GET request on a URL with number 
    being the endpoint and with application/json header''', () {
      // arrange
      callNumberTriviaAPI200();
      // act
      numberTriviaRemoteDataSourceImpl.getRandomNumberTrivia();
      // assert
      verify(mockHttpClient.get(HOST+'random', headers: HEADER));
    });
    
    test('should return NumberTriviaModel when API call is success(200)', () async {
      // arrange
      callNumberTriviaAPI200();
      // act
      final result = await numberTriviaRemoteDataSourceImpl.getRandomNumberTrivia();
      // assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should return ServerException when API call is unsuccess(404 or others)', () async {
      // arrange
      callNumberTriviaAPI404();
      // act
      final call = numberTriviaRemoteDataSourceImpl.getRandomNumberTrivia;
      // assert
      expect(() => call(), throwsA(TypeMatcher<ServerException>()));
    });
  });
}