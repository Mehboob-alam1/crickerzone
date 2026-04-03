import 'package:flutter/material.dart';

class OversTimelineWidget extends StatelessWidget {
  final String currentOver;
  final String bowlerName;
  final List<String> balls;
  final String lastOver;
  final String lastBowlerName;

  const OversTimelineWidget({
    super.key,
    required this.currentOver,
    required this.bowlerName,
    required this.balls,
    required this.lastOver,
    required this.lastBowlerName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overs Timeline',
              style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentOver,
                      style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(bowlerName, style: const TextStyle(color: Colors.black54, fontSize: 11)),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _buildBallCircle('Ball...', isText: true),
                  ...balls.map((ball) => _buildBallCircle(ball)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(lastOver,
                      style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(lastBowlerName, style: const TextStyle(color: Colors.black54, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBallCircle(String val, {bool isText = false}) {
    return Container(
      width: isText ? 45 : 30,
      height: 30,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(val,
            style: TextStyle(
                color: Colors.black,
                fontSize: isText ? 10 : 12,
                fontWeight: isText ? FontWeight.normal : FontWeight.bold)),
      ),
    );
  }
}
