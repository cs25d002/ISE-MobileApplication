require('dotenv').config(); // Load environment variables
const fs = require('fs');
const Tesseract = require('tesseract.js');
const express = require('express');
const axios = require('axios');

const router = express.Router();

// ✅ Gemini API URL
const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`;

// ✅ Function to call Gemini API
async function runGemini(prompt) {
  try {
    const response = await axios.post(
      GEMINI_API_URL,
      { contents: [{ role: "user", parts: [{ text: prompt }] }] },
      { headers: { "Content-Type": "application/json" } }
    );

    const textResponse = response.data.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!textResponse) throw new Error("No response from Gemini");

    return textResponse.trim();
  } catch (error) {
    console.error("❌ Gemini API Error:", error.response?.data || error.message);
    throw new Error("Failed to process text with Gemini");
  }
}

// ✅ Route to process OCR and use Gemini for structured output
router.post('/process-ocr', async (req, res) => {
  console.log("📩 OCR API called with:", req.body);
  const { docID, pid, filename } = req.body;

  if (!docID || !pid || !filename) {
    console.log("❌ Missing parameters");
    return res.status(400).json({ error: 'Missing parameters' });
  }

  const imagePath = `uploads/${docID}/${pid}/prescriptions/${filename}`;
  if (!fs.existsSync(imagePath)) {
    console.log("❌ Image not found:", imagePath);
    return res.status(404).json({ error: "Image not found" });
  }

  try {
    // 🔍 Step 1: Extract text using OCR
    const { data } = await Tesseract.recognize(imagePath, 'eng');
    const extractedText = data.text.trim();
    console.log("📄 Extracted Text:", extractedText);

    // 🔍 Step 2: Process text with Gemini API
    const geminiResponse = await runGemini(
      `Extract key details from this prescription and structure it in JSON format and do NOT include any extra information.:
      {
        "physician": { "name": "", "license": "", "medical_centre": "", "phone": "" },
        "patient": { "name": "", "address": "", "date": "" },
        "medications": [ { "name": "", "dosage": "", "route": "", "frequency": "", "refills": "" } ],
        "signature": ""
      }
      Prescription text:
      ${extractedText}`
    );

    console.log("🤖 Gemini Raw Response:", geminiResponse);
    console.log("Type of geminiResponse:", typeof geminiResponse);

    let cleanedResponse = geminiResponse.trim();

    // // Remove Markdown-style JSON formatting (` ```json ` and ` ``` `)
    // if (cleanedResponse.startsWith("```json")) {
    //     cleanedResponse = cleanedResponse.slice(7); // Remove "```json"
    // }
    // if (cleanedResponse.endsWith("```")) {
    //     cleanedResponse = cleanedResponse.slice(0, -3); // Remove trailing "```"
    // }

    cleanedResponse = cleanedResponse.replace(/```json|```/g, '').trim();

    let parsedData;
    try {
        parsedData = JSON.parse(cleanedResponse);
        
          // Ensure correct JSON parsing
    if (typeof parsedData === "string") {
        parsedData = JSON.parse(parsedData);
    }
    //res.json(parsedData);// Attempt to parse JSON
    } catch (parseError) {
        console.error("❌ JSON Parsing Error:", parseError);
        return res.status(500).json({ error: "Failed to parse Gemini response" });
    }
    console.log("📦 Parsed Data:", parsedData);

    res.json(parsedData);
  } catch (error) {
    console.error("🚨 Error:", error.message);
    res.status(500).json({ error: 'OCR processing failed' });
  }
});

module.exports = router;
