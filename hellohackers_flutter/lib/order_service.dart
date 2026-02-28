import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  static Future<void> createOrder(
      String caseId,
      Map<String, dynamic> caseData) async {

    await _db.collection("orders").add({
      "userEmail": caseData["userEmail"],
      "caseId": caseId,
      "medicine": caseData["prescribedMedicine"],
      "dosage": caseData["dosage"],
      "price": caseData["price"],
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}