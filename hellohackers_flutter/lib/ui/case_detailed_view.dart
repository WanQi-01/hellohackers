import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hellohackers_flutter/core/colors.dart';

class CaseDetailedView extends StatefulWidget {
  final String caseId;
  final String patientName;
  final int patientAge;
  // final List<MedicineItem> medicines;

  const CaseDetailedView({
    super.key,
    required this.caseId,
    required this.patientName,
    required this.patientAge,
    // required this.medicines,
  });

  @override
  State<CaseDetailedView> createState() => _CaseDetailedViewState();
}

class _CaseDetailedViewState extends State<CaseDetailedView> {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController medicineController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();


  // Stream<QuerySnapshot> getMessages() {
  // return _db
  //     .collection('cases')
  //     .where('caseID', isEqualTo: widget.caseId)
  //     .limit(1)
  //     .snapshots();
  // }


  Future<String?> _getCaseDocId() async {
    final query = await _db
        .collection('cases')
        .where('caseID', isEqualTo: widget.caseId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return query.docs.first.id;
  }

    Stream<QuerySnapshot>? _getMessagesStream(String caseDocId) {
      return _db
          .collection('cases')
          .doc(caseDocId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();
    }

    Future<void> _approveCase() async {
      if (medicineController.text.isEmpty || dosageController.text.isEmpty || priceController.text.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text("Note"),
            content: Text("Please fill in all the fields",
            style: TextStyle(fontSize: 16),),
          ),
        );
        return;
      }

      final caseDocId = await _getCaseDocId();
      if (caseDocId == null) return;

      await _db.collection('cases').doc(caseDocId).update({
        'status': 'resolved',
        'prescribedMedicine': medicineController.text,
        'dosage': dosageController.text,
        'price': double.tryParse(priceController.text) ?? 0,
        'orderMethod': "",
      });

      if (!mounted) return;

      // medicineController.clear();
      // dosageController.clear();
      // priceController.clear();
      Navigator.pop(context);
    }

    /// Further assessment dialog
    void _furtherAssessment() async {
      final caseDocId = await _getCaseDocId();
      if (caseDocId == null) return;

      /// 1. Update status first
      await _db.collection('cases').doc(caseDocId).update({
        'status': 'further assessment',
      });

      if (!mounted) return;

      /// 2. Show popup after updating
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Further Assessment"),
          content: const Text(
            "We will connect you to the patient shortly.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close case detail
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    }



  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      insetPadding: const EdgeInsets.all(10),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: const DecorationImage(
            image: AssetImage('assets/images/background_1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<String?>(
          future: _getCaseDocId(),
          builder: (context, snapshot) {
            final caseDocId = snapshot.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ================= CASE INFO =================

                  Text(
                    "Case #${widget.caseId}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: "timess",
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text("Patient Name: ${widget.patientName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "timess")),
                  const SizedBox(height: 8),
                  Text("Age: ${widget.patientAge} years", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,fontFamily: "timess")),

                  const SizedBox(height: 30),

                  /// ================= CHAT MESSAGES =================

                  const Text(
                    "Chat Messages",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: "timess",
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (caseDocId != null)
                    StreamBuilder<QuerySnapshot>(
                      stream: _getMessagesStream(caseDocId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Text("No messages.");
                        }

                        final messages = snapshot.data!.docs;

                        return Column(
                          children: messages.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            final bool isUser = data['isUser'] ?? false;

                            return Align(
                              alignment:
                                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? Colors.white
                                      : AppColors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  data['text'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isUser ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    )
                  else
                    const Text("Loading messages..."),

                  const SizedBox(height: 30),

                  /// ================= PRESCRIPTION INPUT =================

                  const Text(
                    "Prescribe Medicine",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: medicineController,
                    decoration: const InputDecoration(
                      labelText: "Medicine Name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: dosageController,
                    decoration: const InputDecoration(
                      labelText: "Dosage (mg)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: "Price (USD)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 30),

                  /// ================= BUTTONS =================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _approveCase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF00796B),
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                        ),
                        child: const Text(
                          "Approve",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _furtherAssessment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF00796B),
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                        ),
                        child: const Text(
                          "Further Assessment",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Helper to open dialog
void showCaseDetailedView(
  BuildContext context, {
  required String caseId,
  required String patientName,
  required int patientAge,
}) {
  showDialog(
    context: context,
    builder: (_) => CaseDetailedView(
      caseId: caseId,
      patientName: patientName,
      patientAge: patientAge,
    ),
  );
}