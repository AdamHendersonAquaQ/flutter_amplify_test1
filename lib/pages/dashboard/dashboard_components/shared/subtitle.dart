import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:praxis_internals/colour_constants.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/shared/shared.dart';

class Subtitle extends StatelessWidget {
  final VoidCallback? openDrawer;
  final VoidCallback? downloadCsv;

  final TextSpan? tooltip;
  final String? destination;

  final String subtitle;
  final DateTime lastUpdated;
  const Subtitle(
      {super.key,
      this.openDrawer,
      required this.lastUpdated,
      required this.subtitle,
      this.destination,
      this.downloadCsv,
      this.tooltip});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      tooltip != null
                          ? Tooltip(
                              decoration: const BoxDecoration(
                                  color: offWhite,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              richMessage: tooltip,
                              child: subLabel())
                          : subLabel(),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: SizedBox(
                            width: 130,
                            child: LastUpdatedLabel(lastUpdated: lastUpdated)),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    downloadCsv != null
                        ? IconButton(
                            iconSize: 20,
                            onPressed: downloadCsv,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.download),
                            tooltip: "Download as CSV",
                          )
                        : const Text(""),
                    destination != null
                        ? IconButton(
                            iconSize: 20,
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed(destination!);
                            },
                            tooltip: "View expanded",
                          )
                        : const Text(""),
                    openDrawer != null
                        ? IconButton(
                            onPressed: openDrawer,
                            icon: const Icon(Icons.filter_alt_outlined,
                                color: Colors.blue, size: 20),
                            visualDensity: VisualDensity.compact,
                            tooltip: "Filter data",
                          )
                        : const Text(""),
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: noPadDivider,
            ),
          ],
        ));
  }

  Text subLabel() {
    return Text(
      subtitle,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}

class LastUpdatedLabel extends StatelessWidget {
  const LastUpdatedLabel({super.key, required this.lastUpdated, this.timeGap});

  final DateTime lastUpdated;
  final int? timeGap;

  @override
  Widget build(BuildContext context) {
    return DateTime.now().difference(lastUpdated).inSeconds >= (timeGap ?? 30)
        ? SelectableText(
            "Last Updated: ${DateFormat('yyyy/MM/dd kk:mm:ss').format(lastUpdated)}",
            style: const TextStyle(
              fontSize: 12,
            ),
          )
        : Text("Last Updated placeholder",
            style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontSize: 12,
            ));
  }
}
