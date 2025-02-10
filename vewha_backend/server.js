const express = require('express');
const bodyParser = require('body-parser');
const multer = require('multer');
const fs = require('fs-extra');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = 3000;

app.use(bodyParser.json());

// File storage configuration for multer
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const pid = req.body.pid || req.query.pid;
    const folderPath = `uploads/${pid}`;

    if (!fs.existsSync(folderPath)) {
      await fs.ensureDir(folderPath);
    }
    cb(null, folderPath);
  },
  filename: (req, file, cb) => {
    const pid = req.body.pid || req.query.pid;

    if (req.url === '/add-patient') {
      cb(null, `${pid}.jpg`);
    } else if (req.url === '/add-prescription') {
      const documentId = `Doc${uuidv4().slice(0, 8)}.jpg`;
      cb(null, documentId);
    }
  },
});

const upload = multer({ storage });

// JSON file to store patient information
const PATIENT_INFO_FILE = 'patient_info.json';

// Helper to save patient data
const savePatientData = async (data) => {
  let patientData = [];
  if (fs.existsSync(PATIENT_INFO_FILE)) {
    patientData = JSON.parse(await fs.readFile(PATIENT_INFO_FILE, 'utf8'));
  }
  patientData.push(data);
  await fs.writeFile(PATIENT_INFO_FILE, JSON.stringify(patientData, null, 2));
};

// Route to handle patient submission
app.post('/add-patient', upload.single('patientImage'), async (req, res) => {
  try {
    const pid = uuidv4();
    const { name, age, sex, weight, bloodPressure, healthHistory } = JSON.parse(req.body.patientData);

    const patientInfo = {
      pid,
      name,
      age,
      sex,
      weight,
      bloodPressure,
      healthHistory,
    };

    // Save data to JSON file
    await savePatientData(patientInfo);

    res.status(200).json({ message: 'Patient data added successfully!', pid });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Route to handle prescription upload
app.post('/add-prescription', upload.single('prescriptionImage'), (req, res) => {
  try {
    res.status(200).json({ message: 'Prescription uploaded successfully!' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Serve uploaded files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
