import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/error/exception.dart';
import '../models/number_trivia_model.dart';

const HOST = 'http://numbersapi.com/';
const HEADER = {'Content-Type': 'application/json'};

abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/{number} endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);
  
  /// Calls the http://numbersapi.com/random endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    return _getTriviaFromUrl('$HOST$number');
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() {
    return _getTriviaFromUrl(HOST + 'random');
  }
  
  Future<NumberTriviaModel> _getTriviaFromUrl(String url) async {
    final result = await client.get(url, headers: HEADER);
    if (result.statusCode == 200) {
      return Future.value(NumberTriviaModel.fromJson(json.decode(result.body)));
    } else {
      throw ServerException();
    }
  }
}