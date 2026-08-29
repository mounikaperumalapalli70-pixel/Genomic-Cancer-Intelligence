import 'package:flutter/material.dart';
import '../../core/constants/app_typography.dart';

class StatusBarSimulator extends StatelessWidget {
  final String time;

  const StatusBarSimulator({
    super.key,
    this.time = '9:41',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.signal_cellular_alt_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              const Icon(Icons.wifi_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              const Icon(Icons.battery_full_rounded, size: 16, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}
