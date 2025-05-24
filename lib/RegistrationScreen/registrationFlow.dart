import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;

  const StepProgressIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    List<String> steps = ["Personal", "Qualification", "Religion"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(steps.length, (index) {
          bool isActive = index == currentStep;
          bool isCompleted = index < currentStep;

          return Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isActive
                    ? Colors.orange
                    : isCompleted
                    ? Colors.teal
                    : Colors.grey.shade300,
                child: Icon(
                  isCompleted ? Icons.check : Icons.circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                steps[index],
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive || isCompleted ? Colors.black : Colors.grey,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
