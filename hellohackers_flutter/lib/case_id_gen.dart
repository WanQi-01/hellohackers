import 'package:cloud_firestore/cloud_firestore.dart';

class CaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<String> generateCaseId() async {
    return await _db.runTransaction((transaction) async {
      final docRef = _db.collection('case_counter').doc('counter');
      final snapshot = await transaction.get(docRef);

      int currentValue = 0;

      if (!snapshot.exists) {
        // First time
        transaction.set(docRef, {'lastValue': 0});
      } else {
        currentValue = snapshot.get('lastValue');
      }

      int newValue = currentValue + 1;
      transaction.update(docRef, {'lastValue': newValue});

      return _convertToCaseId(newValue);
    });
  }

  static String _convertToCaseId(int value) {
    int letterPart = value ~/ 1000;
    int numberPart = value % 1000;

    String letters = _numberToLetters(letterPart);
    String numbers = numberPart.toString().padLeft(3, '0');

    return "$letters$numbers";
  }

  static String _numberToLetters(int number) {
    List<int> letters = List.filled(4, 0);

    for (int i = 3; i >= 0; i--) {
      letters[i] = number % 26;
      number ~/= 26;
    }

    return letters
        .map((n) => String.fromCharCode(97 + n)) // 97 = 'a'
        .join();
  }
}