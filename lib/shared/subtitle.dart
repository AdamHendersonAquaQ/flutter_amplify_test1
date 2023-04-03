import 'package:flutter/material.dart';

class Subtitle extends StatelessWidget {
  final ValueChanged<int> flipShowFilter;
  final String subtitle;
  const Subtitle(
      {super.key, required this.flipShowFilter, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Text(
                subtitle,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    flipShowFilter(1);
                  },
                  child: const Icon(Icons.filter_alt_outlined,
                      color: Colors.blue, size: 23),
                ))
          ],
        ),
      ),
    );
  }
}
