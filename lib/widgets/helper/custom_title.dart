import 'package:flutter/material.dart';

class CustomTitle extends StatelessWidget {
  const CustomTitle({super.key});

  @override
  Widget build(BuildContext context) {
  return ShaderMask(
    shaderCallback: (bounds) => const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color.fromARGB(255, 2, 61, 141),
        Color.fromARGB(255, 136, 4, 150),
      ],
    ).createShader(bounds),
    blendMode: BlendMode.srcIn, // This blend mode applies the shader to its child.
    child: const Text(
      "Expense Tracker",
      style: TextStyle(
        fontFamily: 'Sharp Sans',
        // Ensure the text has a solid color so the gradient shows through.
        color: Colors.white, 
      ),
    ),
  );
}
}
