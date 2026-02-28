// functions/firebase-admin.js
const admin = require('firebase-admin');

// Use default credentials (works automatically in Firebase Functions)
admin.initializeApp();

const db = admin.firestore();
module.exports = db;
