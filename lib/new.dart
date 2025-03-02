import 'package:flutter/material.dart';


class BalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Balance",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.show_chart, color: Colors.white70),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "-5133.24 LkR",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Please top up your balance to keep your account active.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 24,
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text("Top Up"),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 24,
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Transfer"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}