
import db from "./firebase-admin.js";
import { google } from "googleapis";

const calendar = google.calendar({
  version: "v3",
  auth: new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/calendar"], 
  }),
});

/**
 * Start a Google Meet for the specific caseId
 * Stores the Meet link in Firestore and updates status
 */
export async function pharmacistCall(caseId) {
  try {
    // Create Google Calendar event with Meet link
    const activity = await calendar.events.insert({
      calendarId: "primary",       
      conferenceDataVersion: 1,     
      requestBody: {
        summary: "Pharmacist Consultation",
        description: `Consultation for case ${caseId}`,
        start: { dateTime: new Date().toISOString() },               
        end: { dateTime: new Date(Date.now() + 30 * 60 * 1000).toISOString() }, // 30 mins meeting
        conferenceData: {
          createRequest: {
            requestId: `${caseId}-${Date.now()}`,  // unique ID for this meet
          },
        },
      },
    });

    // extract the Google Meet link
    const meetLink =
      activity?.data?.conferenceData?.entryPoints?.find(
        (ep) => ep.entryPointType === "video"
      )?.uri || null;

    await db.collection("cases").doc(caseId).update({
      status: "Further Assessment Required", 
      callEnabled: true,                  
      meetLink: meetLink,            
      updatedAt: new Date(),
    });

    return {
      success: true,
      meetLink,
      message: "Google Meet started successfully",
    };
  } catch (error) {
    console.error("Failed to start Google Meet", error);
    return {
      success: false,
      error: error.message,
    };
  }
}