import 'package:flutter/material.dart';
import 'package:hellohackers_flutter/core/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'case_card.dart';
import 'dart:convert';

class PharDashboardPage extends StatefulWidget {
  final String staffEmail;
  const PharDashboardPage({super.key, required this.staffEmail});

  @override
  State<PharDashboardPage> createState() => _PharDashboardPageState();
}

class _PharDashboardPageState extends State<PharDashboardPage> {
  bool _showPending = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final List<CaseItem> pendingCases = [];
  // final List<CaseItem> resolvedCases = [];

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/chat_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Header
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background_2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/mediai_logo_noname.png',
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'MediAI',
                          style: TextStyle(
                            fontSize: 32,
                            fontFamily: 'nextsunday',
                            color: AppColors.darkTeal,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _openAdminProf(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/user_prof.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),

          // ListView
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            bottom: 60,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("cases")
                  .where(
                    "status",
                    isEqualTo: _showPending
                        ? "Pending Pharmacist Review"
                        : "resolved",
                  )
                  .snapshots(),

              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Cases Found"));
                }

                // 🔥 FILTER OUT DOCUMENTS WITHOUT caseID
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  // ignore if caseID field missing or empty
                  return data.containsKey("caseID") &&
                        data["caseID"] != null &&
                        data["caseID"].toString().isNotEmpty;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No Valid Cases Found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final data = docs[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: CaseCard(
                        caseId: data["caseID"] ?? "",
                        name: data["userName"] ?? "",
                        age: data["userAge"] ?? 0,
                        status: data["status"] ?? "",
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom buttons
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showPending = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showPending ? AppColors.blue : Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Pending Cases',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 180,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showPending = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_showPending ? AppColors.blue : Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Resolved Cases',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCaseCard(CaseItem caseItem) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 4,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           caseItem.title,
  //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00796B)),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(caseItem.description, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
  //         const SizedBox(height: 8),
  //         Text('Date: ${caseItem.date}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
  //       ],
  //     ),
  //   );
  // }

  void _openAdminProf() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.lightBlue),
              title: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/userLogin');
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('Error'),
                        content: Text('Failed to sign out. Please try again.'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// class CaseItem {
//   final int id;
//   final String title;
//   final String description;
//   final String date;

//   CaseItem({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.date,
//   });
// }