import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_page.dart';
import '../core/colors.dart';

class OrderHistoryPage extends StatelessWidget {
  final String userEmail;

  const OrderHistoryPage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("cases")
            .where("userEmail", isEqualTo: userEmail)
            .where("status", isEqualTo: "resolved")
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Orders Yet"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data = docs[index].data() as Map<String, dynamic>;

              final caseId = data["caseID"] ?? "Unknown";

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long),
                  title: Text("Case: $caseId"),
                  subtitle: Text("Price: RM ${data["price"] ?? "0"}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showOrderDetails(context, data);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 🔥 Show Order Details
  void _showOrderDetails(BuildContext context, Map<String, dynamic> data) {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: Text("Order Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text("Medicine: ${data["prescribedMedicine"] ?? "N/A"}"),
              const SizedBox(height: 6),

              Text("Dosage: ${data["dosage"] ?? "N/A"}"),
              const SizedBox(height: 6),

              Text("Price: RM ${data["price"] ?? "0"}"),
              const SizedBox(height: 6),

              Text("Order Method: ${data["orderMethod"] ?? "Not Selected"}"),
              const SizedBox(height: 6),

              Text("Status: ${data["status"] ?? ""}"),

            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentPage(caseId: data["caseID"] ?? ""),
                  ),
                );
              },
              child: const Text("Make Payment", style: TextStyle(fontSize: 16, color: AppColors.white),),
            ),
          ],
        );
      },
    );
  }
}