const express = require('express');
const bodyParser = require('body-parser');
const multer = require('multer');
const fs = require('fs-extra');
const path = require('path');
const moment = require('moment');

const app = express();
const HOST = "10.0.2.2"
const PORT = 3000;

app.use(bodyParser.json());

const generatePID = () => `PID${Math.floor(1000000 + Math.random() * 9000000)}`;
const generateDocID = () => `DOC${Math.floor(100000 + Math.random() * 900000)}`;
const sanitizeFilename = (name) => name.replace(/[^a-zA-Z0-9]/g, "_");

const readDoctorData = async () => {
    const filePath = 'doctor_info.json';
    if (!fs.existsSync(filePath)) return {};
    return JSON.parse(await fs.readFile(filePath, 'utf8'));
};

const saveDoctorData = async (data) => {
    await fs.writeFile('doctor_info.json', JSON.stringify(data, null, 2));
};

app.post('/register-doctor', async (req, res) => {
    try {
        console.log('req.body:', req.body);
        const { email } = req.body;
        if (!email) return res.status(400).json({ error: 'Email is required' });

        const username = email.split('@')[0];
        let doctors = await readDoctorData();
        let docID = Object.keys(doctors).find(key => doctors[key] === username);
        if (!docID) {
            docID = generateDocID();
            doctors[docID] = username;
            await saveDoctorData(doctors);
        }

        await fs.ensureDir(path.join('uploads', docID));
        res.status(200).json({ message: 'Doctor registered successfully', docID });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

const storage = multer.diskStorage({
    destination: async (req, file, cb) => {
        let folderPath;
        const { docID} = JSON.parse(req.body.patientData || '{}');

        if (req.url === '/add-patient') {
            folderPath = path.join('uploads', docID, 'patient_pics');
        } else if (req.url === '/add-prescription') {
          //console.log('docID:', docID);
          
          const pid = req.body.pid || req.query.pid;
          const docID = req.body.docID || req.query.docID; 
          console.log('pid:', pid);
            folderPath = path.join('uploads', docID, pid, 'prescriptions');
        }
        
        await fs.ensureDir(folderPath);
        cb(null, folderPath);
    },
    filename: (req, file, cb) => {
        let filename;
        const { name } = JSON.parse(req.body.patientData || '{}');
        if (req.url === '/add-patient') {
            filename = `${sanitizeFilename(name)}.jpg`;
        } else if (req.url === '/add-prescription') {
            filename = `${moment().format('YYYYMMDD_HHmm')}.jpg`;
        }
        cb(null, filename);
    }
});

const upload = multer({ storage });

app.post('/add-patient', upload.single('patientImage'), async (req, res) => {
    try {
        const pid = generatePID();
        const patientData = JSON.parse(req.body.patientData);
        const { docID, name } = patientData;
        const sanitizedFilename = sanitizeFilename(name);
        patientData.pid = pid;
        patientData.imagePath = `/uploads/${docID}/patient_pics/${sanitizedFilename}.jpg`;

        const patientFilePath = path.join('uploads', docID, 'patient_info.json');
        let patients = fs.existsSync(patientFilePath) ? JSON.parse(await fs.readFile(patientFilePath, 'utf8')) : [];
        patients.push(patientData);
        await fs.writeFile(patientFilePath, JSON.stringify(patients, null, 2));

        res.status(200).json({ message: 'Patient added successfully!', pid });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.post('/add-prescription', upload.single('prescriptionImage'), (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ error: 'No prescription image uploaded' });
        res.status(200).json({ message: 'Prescription uploaded successfully!' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


app.get('/patients', async (req, res) => {
  const { docID } = req.query;

  if (!docID) {
      return res.status(400).json({ error: "docID is required" });
  }

  const filePath = path.join('uploads', docID, 'patient_info.json');

  if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: "No patient data found" });
  }

  const patientData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  res.json(patientData);
});


app.get('/prescriptions', async (req, res) => {
    const { docID, pid } = req.query;
    
    if (!docID || !pid) {
        return res.status(400).json({ error: 'Missing docID or pid' });
    }

    const folderPath = path.join(__dirname, 'uploads', docID, pid, 'prescriptions');

    if (!fs.existsSync(folderPath)) {
        return res.status(404).json({ error: 'No prescriptions found' });
    }

    try {
        const files = fs.readdirSync(folderPath).map(file => `http://10.0.2.2:3000/uploads/${docID}/${pid}/prescriptions/${file}`);
        res.json(files);
    } catch (error) {
        res.status(500).json({ error: 'Error reading prescription files' });
    }
});

const ocrRoutes = require('./routes/ocr4');  // ✅ Import OCR route

// Use OCR routes
app.use('/', ocrRoutes);  

app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.listen(PORT, () => {
    console.log(`Server is running on http://${HOST}:${PORT}`);
});