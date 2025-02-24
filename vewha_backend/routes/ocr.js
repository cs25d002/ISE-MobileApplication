const fs = require('fs');
const Tesseract = require('tesseract.js');
const express = require('express');
const { exec } = require('child_process');

const router = express.Router();

// Function to run Ollama and get a response

async function runOllama(prompt) {
  return new Promise((resolve, reject) => {
    console.log("🟡 Running Ollama with prompt:", prompt);

    // Escape quotes to avoid issues in shell execution
    const safePrompt = prompt.replace(/"/g, '\\"');

    exec(`ollama run deepseek-r1:7b "${safePrompt}"`, (error, stdout, stderr) => {
      if (error) {
        console.error("❌ Ollama Error:", error.message);
        reject(error.message);
      } else if (stderr) {
        console.error("⚠️ Ollama Stderr:", stderr);
        reject(stderr);
      } else {
        console.log("✅ Ollama Response:", stdout.trim());
        resolve(stdout.trim());
      }
    });
  });
}



// Route to process OCR and use Ollama for text enhancement
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

    // Step 2: Process text with Local LLM (Ollama)
    const ollamaResponse = await runOllama(
      `Format this extracted text as a structured medical prescription:\n\n${extractedText}`
    );

    console.log("Ollama Response:", ollamaResponse);
    res.json({ text: ollamaResponse });

  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({ error: 'OCR processing failed' });
  }
});

module.exports = router;
