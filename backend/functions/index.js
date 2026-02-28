// index.js inside functions folder
import { getPendingCases } from '../hellohackers_flutter/getPendingCases.js';
import { sendToPharmacist } from '../hellohackers_flutter/sendToPharmacist.js';
import { reviewCases } from '../hellohackers_flutter/reviewCases.js';
import { pharmacistCall } from '../hellohackers_flutter/pharmacistCall.js';

const functions = require('firebase-functions'); // Firebase v1/v2 API
const express = require('express');
const cors = require('cors');
const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();   // Load .env variables
const admin = require('firebase-admin');

admin.initializeApp();       // initialize Firestore
const db = admin.firestore();

// Initialize Express
const app = express();
app.use(express.json());
app.use(cors());

// Initialize Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);

const persona = `
You are a pharmacy AI assistant.

RULES:
  1. First ask: "Is this consultation for yourself?"
  2. If yes → continue symptom collection.
  3. If no → ask age group.
  4. Suggest appropriate medication to the pharmacist
  5. Do NOT prescribe medication.
  6. Always say case will be reviewed by pharmacist.
`;

const model = genAI.getGenerativeModel({
  model: "gemini-2.5-flash",
  systemInstruction: persona
});

// In-memory store for active conversations
let activeCases = {};

app.get('/', (req, res) => {
  res.send('Server is running...');
});

app.post('/chat', async (req, res) => {
  try {
    const sessionKey = req.body.sessionKey || "default";

    if (!activeCases[sessionKey]) {
      activeCases[sessionKey] = {
        caseId: null,
        conversation: []
      };
    }

    const userMessage = req.body.chat?.trim();
    let prompt;

    if (!userMessage && activeCases[sessionKey].conversation.length === 0) {
      prompt = "Start the conversation as a friendly pharmacy assistant. Ask: 'Is this consultation for yourself?'";
    } else {
      if (userMessage) {
        activeCases[sessionKey].conversation.push({ role: "user", content: userMessage });
      }
      prompt = activeCases[sessionKey].conversation
        .map(msg => (msg.role === "user" ? `Patient: ${msg.content}` : `AI: ${msg.content}`))
        .join("\n");
    }

    const result = await model.generateContent(prompt);
    const aiReply = result.response.text();

    activeCases[sessionKey].conversation.push({ role: "assistant", content: aiReply });

    // Save to Firestore
    if (!activeCases[sessionKey].caseId) {
      const docRef = await db.collection("cases").add({
        conversation: activeCases[sessionKey].conversation,
        status: "Pending Pharmacist Review",
        createdAt: new Date()
      });
      activeCases[sessionKey].caseId = docRef.id;
    } else {
      await db.collection("cases")
        .doc(activeCases[sessionKey].caseId)
        .update({
          conversation: activeCases[sessionKey].conversation,
          updatedAt: new Date()
        });
    }

    res.json({
      caseId: activeCases[sessionKey].caseId,
      reply: aiReply
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "AI processing failed" });
  }
});

async function generateAiSuggestion(conversation) {
  const symptomsText = conversation
    .filter(msg => msg.role === "user")
    .map(msg => msg.content)
    .join("\n");

  if (!symptomsText) return null;

  const prompt = `
You are a pharmacy Ai assistant.

Based on the patient's symptoms below:
- Suggest Possible OTC medications
- Include TYPICAL OTC DOSAGE RANGES (not prescriptions)
- Do NOT personalize dosage
- Do NOT prescribe medication

Return STRICT JSON ONLY in this format:

{
  "possibleOTC": [
    {
      "name": "",
      "typicalDoseRange": "",
      "notes": ""
    }
  ],
  "warnings": [],
  "urgencyLevel": "low | medium | high",
  "disclaimer": "This is Ai-generated suggestion. Pharmacist must verify before dispensing."
}

Patient symptoms:
${symptomsText}
`;

  const result = await model.generateContent(prompt);

  try {
    return JSON.parse(result.response.text());
  } catch (err) {
    console.error("Failed to parse AI suggestion");
    return null;
  }
}

app.post("/ai-suggestion", async (req, res) => {
  try {
    const { caseId } = req.body;

    if (!caseId) {
      // 400: invalid data
      return res.status(400).json({ error: "caseId is required" });
    }

    const caseRef = db.collection("cases").doc(caseId);
    const caseGet = await caseRef.get();

    if (!caseGet.exists) {
      return res.status(404).json({ error: "Case not found" });
    }

    const { conversation = [] } = caseGet.data();

    const aiSuggestion = await generateAiSuggestion(conversation);

    if (!aiSuggestion) {
      return res.status(400).json({ error: "No symptoms available for analysis" });
    }

    // Save AI suggestion for pharmacist review
    await caseRef.update({
      aiSuggestion,
      aiSuggestedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    res.json({
      success: true,
      aiSuggestion
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "AI suggestion failed" });
  }
});

// Pharmacist routes
// Get pending cases
app.get('/pending-cases', async (req, res) => {
  try {
    const cases = await getPendingCases();
    res.json({ success: true, cases });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Send content to pharmacist
app.post('/send-to-pharmacist', async (req, res) => {
  try {
    const { caseId } = req.body;
    const result = await sendToPharmacist({ caseId });
    res.json(result);
  } catch (error) {
    // 500: Internal Server error
    res.status(500).json({ success: false, error: error.message });
  }
});

// Review user case
app.post('/review-case', async (req, res) => {
  try {
    const { caseId, selection } = req.body;
    const result = await reviewCases(caseId, selection);
    res.json(result);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Pharmacist call user
app.post('/pharmacist-call', async (req, res) => {
  try {
    const { caseId } = req.body;
    const result = await pharmacistCall(caseId);
    res.json(result);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Export as Firebase Function
exports.api = functions.https.onRequest(app);