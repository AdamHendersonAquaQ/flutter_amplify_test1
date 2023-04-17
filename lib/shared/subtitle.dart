import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Subtitle extends StatelessWidget {
  final ValueChanged<int> flipShowFilter;
  final String subtitle;
  DateTime lastUpdated;
  Subtitle(
      {super.key,
      required this.flipShowFilter,
      required this.lastUpdated,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    subtitle,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  if (DateTime.now().difference(lastUpdated).inSeconds >= 10)
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 5),
                      child: Text(
                        "Last Update: ${DateFormat('yyyy/MM/dd kk:mm:ss').format(lastUpdated)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
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
