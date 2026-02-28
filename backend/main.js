/** Package to enable CORS to handle requests from all domains. */
import cors from 'cors';


/** Framework for building RESTful APIs. */ 
import express from 'express';

/** Package to use the Gemini API. */
import { GoogleGenerativeAI } from '@google/generative-ai';

import 'dotenv/config';   // automatically loads .env variables

/** 
 * To start a new application using Express, put and apply Express into the app variable. */
const app = express ();
app.use(express.json());

/** Apply the CORS middleware. */
app.use(cors())

/** Enable and listen to port 9000. */
const PORT = process.env.PORT || 9000;
app.listen(PORT, () => {
  console.log('Server Listening on PORT:', PORT);
});

/** Access the API key and initialize the Gemini SDK. */
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);

// Setting a system persona
// Define the "rules" for the AI
const persona = 'You are a pharmacy AI assistant. Collect patient symptoms clearly. If symptoms indicate emergency (chest pain, difficulty breathing, severe bleeding), respond with "HIGH_RISK". Otherwise provide OTC suggestion safely.'

/** 
 * Initialize the Gemini model that will generate responses based on the 
 * user's queries. */
const model = genAI.getGenerativeModel({ 
    model: "gemini-2.5-flash",
    systemInstruction: persona
 });
 
app.post("/chat", async (req, res) => {
    /** Read the request data. */
    try {
        let msg = req.body.chat;

        if (!msg) {
            msg = "Start the conversation by greeting the patient and asking how you can help.";
        }

        const result = await model.generateContent(msg);
        const text = result.response.text();

        let riskLevel = "LOW";
        if (text.includes("HIGH_RISK")) {
            riskLevel = "HIGH";
        }

        res.send({
            text: text,
            risk: riskLevel
        });

    } catch (error) {
        console.error(error);
        res.status(500).send({error: "AI processing failed"});
    }
  });