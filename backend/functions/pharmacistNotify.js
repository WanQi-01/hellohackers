import db from "./firebase-admin.js"; 
import admin from "firebase-admin";

export async function sendToPharmacist({ caseId }) {
  try {
    if (!caseId) {
      throw new Error("caseId is required");
    }

    const docRef = db.collection("cases").doc(caseId); 
    const doc = await docRef.get();
    if (!doc.exists) throw new Error("Case not found");

    const lastMessage = data.lastMessage || "No message provided";
    const createdAt = data.createdAt || admin.firestore.FieldValue.serverTimestamp();

     await docRef.update({
      status: "Pending Pharmacist Review",
      pharmacistSentAt: admin.firestore.FieldValue.serverTimestamp(),
      lastMessage: lastMessage,
      createdAt: createdAt,
    });

    // successfully send to pharmacist
    return { success: true, userMessage };
  } catch (error) {
    console.error("Failed to send to pharmacist", error)
    return {
      success: false,
      error: error.message
    };
  }
}
