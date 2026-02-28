import db from "./firebase-admin.js";

export async function getPendingCases() {
  const cases = await db
    .collection("cases")
    .where("status", "Pending Pharmacist Review")
    .get();

  // if no cases
  if (cases.empty) {
    return []; 
  }

  const pendingCases = [];
  cases.forEach(doc => {
    const data = doc.data();
    pendingCases.push({
      caseId: doc.id,
      lastMessage: data.lastMessage || "",
      createdAt: data.createdAt?.toDate().toISOString() || "", 
      userEmail: data.userEmail || "",
      status: data.status || ""
    });
  });

  return pendingCases;
}