import 'package:dartz/dartz.dart';

import '../error/failure.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String numberString) {
    try {
      int result = int.parse(numberString);
      if (result < 0) throw FormatException();
      return Right(result);
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }
}