import 'package:flutter/material.dart';

import 'tape.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff9bf44),
      child: Center(
        child: Tape()
      ),
    );
  }

}