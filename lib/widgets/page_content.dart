import 'package:flutter/material.dart';

class PageContent extends StatelessWidget {
  final String imageAsset;
  final String text;

  const PageContent({super.key, required this.imageAsset, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Image.asset(imageAsset)),
        Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
