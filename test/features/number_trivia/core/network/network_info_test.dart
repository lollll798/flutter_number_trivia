import 'package:clean_arch_tdd/features/number_trivia/core/network/network_info.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockDataConnectionChecker extends Mock implements DataConnectionChecker{}

void main() {
  late MockDataConnectionChecker mockDataConnectionChecker;
  late NetworkInfoImpl networkInfoImpl;

  setUp(() {
    mockDataConnectionChecker = MockDataConnectionChecker();
    networkInfoImpl = NetworkInfoImpl(mockDataConnectionChecker);
  });

  group('isConnected', () {
    final tHasConnectionFuture = Future.value(true);
    test('should forward the call to DataConnectionChecker.hasConnection', () async {
      // arrange
      when(mockDataConnectionChecker.hasConnection).thenAnswer((_) => tHasConnectionFuture);
      // act
      final result = networkInfoImpl.isConnected;
      // assert
      expect(result, tHasConnectionFuture);
    });
  });
}