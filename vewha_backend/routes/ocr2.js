const fs = require('fs');
const Tesseract = require('tesseract.js');
const express = require('express');
const axios = require('axios');

const router = express.Router();



// Function to call OpenAI GPT-4 API
async function runGPT4(prompt) {
  try {
    const response = await axios.post(
      "https://api.openai.com/v1/chat/completions",
      {
        model: "gpt-4",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.7,
      },
      {
        headers: {
          "Authorization": `Bearer ${process.env.OPENAI_API_KEY}`,
          "Content-Type": "application/json",
        },
      }
    );

    return response.data.choices[0].message.content.trim();
  } catch (error) {
    console.error("❌ GPT-4 API Error:", error.response?.data || error.message);
    throw new Error("Failed to process text with GPT-4");
  }
}

// Route to process OCR and use GPT-4 for text enhancement
router.post('/process-ocr', async (req, res) => {
  console.log("OCR API called with:", req.body);
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
    // Step 1: Extract text using OCR
    const { data } = await Tesseract.recognize(imagePath, 'eng');
    const extractedText = data.text.trim();
    console.log("Extracted Text:", extractedText);

    // Step 2: Process text with GPT-4 API
    const gptResponse = await runGPT4(
      `Format this extracted text as a structured medical prescription:\n\n${extractedText}`
    );

    console.log("GPT-4 Response:", gptResponse);
    res.json({ text: gptResponse });

  } catch (error) {
    console.error("Error:", error.message);
    res.status(500).json({ error: 'OCR processing failed' });
  }
});

module.exports = router;
