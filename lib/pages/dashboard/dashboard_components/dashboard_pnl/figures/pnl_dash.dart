import 'package:flutter/material.dart';
import 'package:praxis_internals/pages/dashboard/dashboard_components/dashboard_pnl/figures/pnl_widget.dart';

class PnLDash extends StatefulWidget {
  const PnLDash({super.key});

  @override
  State<PnLDash> createState() => _PnLDashState();
}

class _PnLDashState extends State<PnLDash> {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 50, child: PnLWidget(endpoint: "pnl", label: "Client")),
      ],
    );
  }
}
