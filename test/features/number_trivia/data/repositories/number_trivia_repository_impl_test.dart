import 'package:clean_arch_tdd/features/number_trivia/core/error/exception.dart';
import 'package:clean_arch_tdd/features/number_trivia/core/error/failure.dart';
import 'package:clean_arch_tdd/features/number_trivia/core/network/network_info.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_arch_tdd/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_arch_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockNumberTriviaRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockNumberTriviaLocalDataSource extends Mock
    implements NumberTriviaLocalDataSource {}

final tNumber = 1;
final tNumberTriviaModel =
    NumberTriviaModel(number: tNumber, text: 'test trivia');
final NumberTrivia tNumberTrivia = tNumberTriviaModel;

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockNetworkInfo mockNetworkInfo;
  late MockNumberTriviaRemoteDataSource mockNumberTriviaRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockNumberTriviaLocalDataSource;

  setUp(() {
    mockNumberTriviaRemoteDataSource = new MockNumberTriviaRemoteDataSource();
    mockNumberTriviaLocalDataSource = new MockNumberTriviaLocalDataSource();
    mockNetworkInfo = new MockNetworkInfo();
    repository = new NumberTriviaRepositoryImpl(
        remoteDataSource: mockNumberTriviaRemoteDataSource,
        localDataSource: mockNumberTriviaLocalDataSource,
        networkInfo: mockNetworkInfo);
  });

  void runTestOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      
      body();
    });
  }

  void runTestOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    test('should check if the device is online', () {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      repository.getConcreteNumberTrivia(tNumber);
      // assert
      verify(mockNetworkInfo.isConnected);
    });
    
    // device online
    // get remote data source
    // cache number trivia
    // return server failure

    runTestOnline(() {
      test('should return remote data when call the remote data source success',
          () async {
        // arrange
        when(mockNumberTriviaRemoteDataSource
                .getConcreteNumberTrivia(any as dynamic))
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should cache data locally when call the remote data source success',
          () async {
        // arrange
        when(mockNumberTriviaRemoteDataSource
                .getConcreteNumberTrivia(any as dynamic))
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(mockNumberTriviaLocalDataSource
            .cacheNumberTrivia(tNumberTriviaModel));
      });

      test(
          'should return server failure while call the remote data source unsuccess',
          () async {
        // arrange
        when(mockNumberTriviaRemoteDataSource
                .getConcreteNumberTrivia(any as dynamic))
            .thenThrow(ServerException());
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockNumberTriviaRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockNumberTriviaLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    // device offline
    // get last record
    // cache exception
    runTestOffline(() {
      test('should return last locally cached data when cached data is present',
          () async {
        // arrange
        when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
        verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return Cache Failure when there is no cache data present',
          () async {
        // arrange
        when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        // act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
        verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    test('should check if the device is online', () {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      repository.getRandomNumberTrivia();
      // assert
      verify(mockNetworkInfo.isConnected);
    });
    
    // device online
    // get remote data source
    // cache number trivia
    // return server failure

    runTestOnline(() {
      test('should return remote data when call the remote data source success',
          () async {
        // arrange
        when(mockNumberTriviaRemoteDataSource
                .getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should cache data locally when call the remote data source success',
          () async {
        // arrange
        when(mockNumberTriviaRemoteDataSource
                .getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        await repository.getRandomNumberTrivia();
        // assert
        verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());
        verify(mockNumberTriviaLocalDataSource
            .cacheNumberTrivia(tNumberTriviaModel));
      });

      test(
          'should return server failure while call the remote data source unsuccess',
          () async {
        // arrange
        when(mockNumberTriviaRemoteDataSource
                .getRandomNumberTrivia())
            .thenThrow(ServerException());
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verify(mockNumberTriviaRemoteDataSource.getRandomNumberTrivia());
        verifyZeroInteractions(mockNumberTriviaLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    // device offline
    // get last record
    // cache exception
    runTestOffline(() {
      test('should return last locally cached data when cached data is present',
          () async {
        // arrange
        when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
        verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return Cache Failure when there is no cache data present',
          () async {
        // arrange
        when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        // act
        final result = await repository.getRandomNumberTrivia();
        // assert
        verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
        verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}
