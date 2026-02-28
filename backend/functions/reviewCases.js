import db from "./firebase-admin.js";
import admin from "firebase-admin";

export async function reviewCases(caseId, selection) {
  // if choice not in selections
  if (!["approved", "furtherAssessment"].includes(selection)) {
    throw new Error("Invalid option, choose again.")
  }

  let newStatus; // create new variable
  let aiMessage;

  if (selection === "approved") {
    newStatus = "Approved";
    aiMessage = "Your case have been approved. You can either self-collect your medicine or delivery instantly now."
  } else {
    newStatus = "Further Assessment Required"
    aiMessage = "Your case is required for further assessment. The pharmacist will contact you sooner."
  }

  await db.collection("cases").doc(caseId).update({
    status: newStatus,
    reviewedAt: admin.firestore.FieldValue.serverTimestamp()
  });

  return {
    success: true,
    aiMessage
  };
}