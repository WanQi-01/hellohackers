import 'dart:isolate';
import 'dart:async';

import 'package:hellohackers_flutter/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:hellohackers_flutter/api_service.dart';
import 'package:hellohackers_flutter/ui/profile_page.dart'; // Add your profile page
import 'package:hellohackers_flutter/ui/payment_page.dart'; // Add your payment page
import 'package:firebase_auth/firebase_auth.dart'; // Add for auth
import 'package:cloud_firestore/cloud_firestore.dart';

import '../case_id_gen.dart';
import '../chat_message.dart';
import "../chat_service.dart";
import '../order_service.dart';
import 'order_history.dart';

class UserDashboardPage extends StatefulWidget {
  final String userEmail;

  const UserDashboardPage({super.key, required this.userEmail});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? curCaseId;

  String responseText = "";
  bool _isLoading = false;
  bool _resolvedMessageSent = false;
  bool _furtherMessageSent = false;

  List<ChatMessage> messages = [];
  List<String> previousCaseIds = [];
  StreamSubscription? _chatSubscription;
  StreamSubscription? _caseStatusSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildChatHistoryDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/chat_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 80,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background_2.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  // Menu button
                  GestureDetector(
                    onTap: () => _showMenu(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, top: 20),
                      child: Icon(
                        Icons.menu,
                        color: AppColors.darkTeal,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                      top: 10,
                    ),
                    child: Image.asset(
                      'assets/images/mediai_logo_noname.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 70, top: 20),
                        child: Text(
                          'MediAI',
                          style: const TextStyle(
                            fontSize: 35,
                            fontFamily: 'nextsunday',
                            color: AppColors.darkTeal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Profile icon - UPDATED to navigate to full profile
                  GestureDetector(
                    onTap: () => _navigateToProfile(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10, top: 10),
                      child: Image.asset(
                        'assets/images/user_prof.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chat Messages ListView (rest of your existing code remains the same)
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'Start chatting with MediBot!',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return _buildChatBubble(message);
                      },
                    ),
            ),

            // Input area (your existing code)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.transparent,
              child: Row(
                children: [

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(

                      controller: messageController,
                      style: const TextStyle(fontSize: 16),

                      minLines: 1,
                      maxLines: 5,

                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,

                      decoration: InputDecoration(
                        hintText: 'Send a message',
                        hintStyle: TextStyle(color: AppColors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    ),
                  ),
                  const SizedBox(width: 8),


                  //send icon
                  ///////////////////////////////////////////////////////////
                  ///CHECKED
                  GestureDetector(
                    onTap: () async {
                      if (messageController.text.trim().isEmpty) return;

                      String userMessage = messageController.text;

                      if (curCaseId == null) {
                        // First time sending a message, create a new case
                        String newCaseId = await CaseService.generateCaseId();
                        await ChatService.createCase(
                          caseId: newCaseId,
                          userEmail: widget.userEmail,
                        );
                        curCaseId = newCaseId;
                        // previousCaseIds.add(newCaseId);
                      }

                      //add user msg to database under case, and to the current messages list
                      await ChatService.addMessage(
                        caseId: curCaseId!,
                        text: userMessage,
                        isUser: true,
                      );

                      setState(() {
                        messages.add(ChatMessage(
                          text: userMessage,
                          isUser: true,
                        ));
                        _isLoading = true;
                      });

                      messageController.clear();
                      _scrollToBottom();

                      //add ai reply to database and to the current messages list
                      String aiReply = await ApiService.sendMessage(userMessage, curCaseId!);

                      await ChatService.addMessage(caseId: curCaseId!, text: aiReply, isUser: false,);

                      setState(() {
                        messages.add(ChatMessage(text: aiReply, isUser: false));
                        _isLoading = false;
                      });

                      _scrollToBottom();
                    },
                    /////////////////////////////////////////////////

                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }


  Widget _buildChatHistoryDrawer() {
  return Drawer(
    child: Column(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: AppColors.lightBlue),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              "Previous Chats",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // List of case IDs
        Expanded(
          child: Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("cases")
                  .where("userEmail", isEqualTo: widget.userEmail)
                  // .orderBy("createdAt", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No Previous Chats"),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final data = docs[index].data() as Map<String, dynamic>;
                    final caseId = data["caseID"] ?? "Unknown ID";

                    // final caseId = docs[index].id;

                    return ListTile(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text("Case $caseId"),
                      subtitle: Text("Status: ${data["status"] ?? ""}"),
                      onTap: () {
                        Navigator.pop(context);
                        _loadChat(caseId);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    ),
  );


}

  /////CHECKED
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  ///CHECKED
  Widget _buildChatBubble(ChatMessage message) {
    if (!message.isUser &&
      message.text.contains("Choose your order method")) {
        return _buildOrderButtons();
      }

    return Container(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.teal700 : AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 15,
            color: message.isUser ? AppColors.white : AppColors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        ElevatedButton(
          onPressed: () {
            _selectPickup();
          },
          child: const Text("Self Pickup", style: TextStyle(fontSize: 14, color: AppColors.white),),
        ),

        const SizedBox(width: 10),

        ElevatedButton(
          onPressed: () {
            _selectDelivery();
          },
          child: const Text("Delivery", style: TextStyle(fontSize: 14, color: AppColors.white)),
        ),
      ],
    );
  }

  void _showAlreadyChosenDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Order Method"),
        content: const Text(
            "You have already chosen an order method. You cannot change it."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _selectPickup() async {
    if (curCaseId == null) return;

    // ---------------------------------------
    // 1. Get order document
    // ---------------------------------------
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection("orders")
        .where("caseId", isEqualTo: curCaseId)
        .limit(1)
        .get();

    if (ordersSnapshot.docs.isNotEmpty) {
      final data = ordersSnapshot.docs.first.data();
      final existingMethod = data["orderMethod"] ?? "";

      if (existingMethod.toString().isNotEmpty) {
        _showAlreadyChosenDialog();
        return;
      }
    }

    // ---------------------------------------
    // 2. Update case status -> resolved
    // ---------------------------------------
    // final caseSnapshot = await FirebaseFirestore.instance
    //     .collection("cases")
    //     .where("caseID", isEqualTo: curCaseId)
    //     .limit(1)
    //     .get();

    // if (caseSnapshot.docs.isNotEmpty) {
    //   await caseSnapshot.docs.first.reference.update({
    //     "status": "resolved",
    //   });
    // }

    // ---------------------------------------
    // 3. Update order method
    // ---------------------------------------
    for (var doc in ordersSnapshot.docs) {
      await doc.reference.update({
        "orderMethod": "self pickup",
      });
    }

    // ---------------------------------------
    // 4. Add chat message
    // ---------------------------------------
    await ChatService.addMessage(
      caseId: curCaseId!,
      text: "User selected Self Pickup.",
      isUser: true,
    );

    await ChatService.addMessage(
      caseId: curCaseId!,
      text: "Please proceed to the order history page to view your order details and pay for your order.",
      isUser: false,
    );
  }

  void _selectDelivery() async {
    if (curCaseId == null) return;

    // ---------------------------------------
    // 1. Check user address
    // ---------------------------------------
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: widget.userEmail)
        .limit(1)
        .get();

    String address = "";

    if (userDoc.docs.isNotEmpty) {
      final data = userDoc.docs.first.data();
      address = data["address"] ?? "";
    }

    if (address.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Note"),
          content: const Text("Please add your delivery address in your profile."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
);

return;
    }

    // ---------------------------------------
    // 2. Check if order already chosen
    // ---------------------------------------
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection("orders")
        .where("caseId", isEqualTo: curCaseId)
        .limit(1)
        .get();

    if (ordersSnapshot.docs.isNotEmpty) {
      final data = ordersSnapshot.docs.first.data();
      final existingMethod = data["orderMethod"] ?? "";

      if (existingMethod.toString().isNotEmpty) {
        _showAlreadyChosenDialog();
        return;
      }
    }

    // ---------------------------------------
    // 3. Update case status
    // ---------------------------------------
    // final caseSnapshot = await FirebaseFirestore.instance
    //     .collection("cases")
    //     .where("caseID", isEqualTo: curCaseId)
    //     .limit(1)
    //     .get();

    // if (caseSnapshot.docs.isNotEmpty) {
    //   await caseSnapshot.docs.first.reference.update({
    //     "status": "resolved",
    //   });
    // }

    // ---------------------------------------
    // 4. Update order
    // ---------------------------------------
    for (var doc in ordersSnapshot.docs) {
      await doc.reference.update({
        "orderMethod": "delivery",
      });
    }

    // ---------------------------------------
    // 5. Add chat message
    // ---------------------------------------
    await ChatService.addMessage(
      caseId: curCaseId!,
      text: "✔ User selected Delivery.\nAddress: $address",
      isUser: true,
    );
        await ChatService.addMessage(
      caseId: curCaseId!,
      text: "Please proceed to the order history page to view your order details and pay for your order.",
      isUser: false,
    );
  }

  ///CHECKED
  void _showMenu() {
    // You can add menu items here later
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: AppColors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Menu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add, color: AppColors.lightBlue),
              title: const Text('New Chat'),
              onTap: () {
                Navigator.pop(context);
                _navigateToNewChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: AppColors.lightBlue),
              title: const Text('Previous Chats'),
              onTap: () {
                Navigator.pop(context);
                _navigateToSidePanel();
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.payment, color: AppColors.lightBlue),
            //   title: const Text('Make a Payment'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     _navigateToPayment();
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.lightBlue),
              title: const Text('Order History'),
              onTap: () => {
                Navigator.pop(context),
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderHistoryPage(userEmail: widget.userEmail),
                  ),
                ),
              },

            ),
            ListTile(
              leading: const Icon(Icons.help, color: AppColors.lightBlue),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Help & Support');
              },
            ),
          ],
        ),
      ),
    );
  }

  //add save chat history
  void _navigateToNewChat() {
    if (curCaseId != null && !previousCaseIds.contains(curCaseId)) {
      previousCaseIds.add(curCaseId!);
    }

    setState(() {
      messages.clear();
      curCaseId = null;
    });
  }


  void _navigateToSidePanel() {
    _scaffoldKey.currentState?.openDrawer();
  }

  /////to check
  void _loadChat(String caseId) async {
    // Cancel any existing subscription to avoid multiple listeners
    await _chatSubscription?.cancel();

    _chatSubscription = ChatService.getCaseMessages(caseId).listen((snapshot) {
      List<ChatMessage> fetchedMessages = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ChatMessage(
          text: data['text'] ?? '',
          isUser: data['isUser'] ?? false,
        );
      }).toList();

      setState(() {
        curCaseId = caseId;
        messages = fetchedMessages;
      });

      _scrollToBottom();
    });

    // Listen to case status changes
    _caseStatusSubscription = FirebaseFirestore.instance
        .collection("cases")
        .where("caseID", isEqualTo: caseId)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) return;

      final data = snapshot.docs.first.data();
      final status = data["status"];

      /// ---------------- RESOLVED ----------------
      if (status == "resolved" && !_resolvedMessageSent) {
        _resolvedMessageSent = true;

        final medicine = data["prescribedMedicine"] ?? "";
        final dosage = data["dosage"] ?? "";
        final price = data["price"] ?? "";

        String autoMessage =
        """
        Prescription Completed

        Medicine: $medicine
        Dosage: $dosage
        Price: $price

        Choose your order method:
        """;

        await ChatService.addMessage(
          caseId: caseId,
          text: autoMessage,
          isUser: false,
        );

        await OrderService.createOrder(caseId, data);

  }

        /// ---------------- FURTHER ASSESSMENT ----------------
        if (status == "further assessment"  && !_furtherMessageSent) {
          _furtherMessageSent = true;

          await ChatService.addMessage(
            caseId: caseId,
            text:
                "The pharmacist will contact you soon for further assessment.",
            isUser: false,
          );
        }
      });
  }

  // NEW: Navigate to full profile page
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  // // NEW: Navigate to payment page
  // void _navigateToPayment() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const PaymentPage(),
  //     ),
  //   );
  // }

  // Helper for showing coming soon features
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.lightBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _caseStatusSubscription?.cancel();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


}