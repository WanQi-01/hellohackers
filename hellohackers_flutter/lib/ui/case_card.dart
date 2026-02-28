import 'package:flutter/material.dart';
import 'package:hellohackers_flutter/core/colors.dart';
import 'case_detailed_view.dart';

class CaseCard extends StatelessWidget {
  final String caseId;
  final String name;
  final int age;
  final String status;

  const CaseCard({
    super.key,
    required this.caseId,
    required this.name,
    required this.age,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        showCaseDetailedView(
          context,
          caseId: caseId,
          patientName: name,
          patientAge: age,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.ashBlue,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Case: $caseId",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text("Name: $name"),
            Text("Age: $age"),
            const SizedBox(height: 6),
            Text(
              status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: status == "Resolved"
                    ? AppColors.callGreen
                    : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}