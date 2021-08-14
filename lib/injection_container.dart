import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'features/number_trivia/core/network/network_info.dart';
import 'features/number_trivia/core/util/input_converter.dart';
import 'features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'features/number_trivia/domain/repositories/number_trivia_repositories.dart';
import 'features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

final serviceLocation = GetIt.instance;

Future<void> init() async {
  //! Features - Number Trivia
  //* Bloc
  serviceLocation.registerFactory(
    () => NumberTriviaBloc(
      concrete: serviceLocation(),
      random: serviceLocation(),
      inputConverter: serviceLocation(),
    ),
  );
  
  //* Use Cases
  serviceLocation.registerLazySingleton(
    () => GetConcreteNumberTrivia(
      serviceLocation(),
    ),
  );
  serviceLocation.registerLazySingleton(
    () => GetRandomNumberTrivia(
      serviceLocation(),
    ),
  );
  
  //* Repository
  serviceLocation.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      remoteDataSource: serviceLocation(),
      localDataSource: serviceLocation(),
      networkInfo: serviceLocation(),
    ),
  );

  //* Data sources
  serviceLocation.registerLazySingleton<NumberTriviaRemoteDataSource>(
    () => NumberTriviaRemoteDataSourceImpl(client: serviceLocation()),
  );

  serviceLocation.registerLazySingleton<NumberTriviaLocalDataSource>(
    () => NumberTriviaLocalDataSourceImpl(serviceLocation()),
  );

  //! Core
  serviceLocation.registerLazySingleton(() => InputConverter());
  serviceLocation.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(serviceLocation()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocation.registerLazySingleton(() => sharedPreferences);
  serviceLocation.registerLazySingleton(() => http.Client());
  serviceLocation.registerLazySingleton(() => DataConnectionChecker());
}
