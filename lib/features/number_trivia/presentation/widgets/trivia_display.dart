import 'package:clean_arch_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter/cupertino.dart';

class TriviaDisplay extends StatelessWidget {
  final NumberTrivia trivia;

  const TriviaDisplay({Key? key, required this.trivia}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        children: [
          Text(
            trivia.number.toString(),
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  trivia.text,
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
