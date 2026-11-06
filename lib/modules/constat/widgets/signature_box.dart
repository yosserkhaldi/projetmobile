import 'package:flutter/material.dart';

class SignatureBox extends StatelessWidget {
  const SignatureBox(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    height: 130,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Center(
      child: Text('$label\nSignez ici', textAlign: TextAlign.center),
    ),
  );
}
