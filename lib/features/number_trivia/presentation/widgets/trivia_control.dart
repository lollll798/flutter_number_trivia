
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/number_trivia_bloc.dart';


class TriviaControl extends StatefulWidget {
  const TriviaControl({
    Key? key,
  }) : super(key: key);

  @override
  State<TriviaControl> createState() => _TriviaControlState();
}

class _TriviaControlState extends State<TriviaControl> {
  final controller = TextEditingController();
  late String inputStr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Input a positive number'),
          onChanged: (value) {
            inputStr = value;
          },
          onSubmitted: (_) => dispatchConcrete(),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Expanded(
              child: RaisedButton(
                child: Text('Search'),
                color: Theme.of(context).accentColor,
                textTheme: ButtonTextTheme.primary,
                onPressed: dispatchConcrete,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: RaisedButton(
                child: Text('Get random trivia'),
                onPressed: dispatchRandom,
              ),
            ),
          ],
        )
      ],
    );
  }

  void dispatchConcrete() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context).add(
      GetTriviaForConcreteNumber(inputStr),
    );
  }

  void dispatchRandom() {
    BlocProvider.of<NumberTriviaBloc>(context).add(
      GetTriviaForRandomNumber(),
    );
  }
}
