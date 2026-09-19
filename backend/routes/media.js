const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { speechToText, textToSpeech } = require('../utils/nvidiaService');

// Configure upload storage for SC Caste Certificates
const uploadDir = path.join(__dirname, '../uploads/certificates');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const uniqueName = `sc_cert_${Date.now()}_${Math.round(Math.random() * 1e9)}${ext}`;
    cb(null, uniqueName);
  },
});

// Requirement 3: File type and 5 MB size validation
const fileFilter = (req, file, cb) => {
  const allowedExts = ['.pdf', '.doc', '.docx', '.png', '.jpg', '.jpeg'];
  const ext = path.extname(file.originalname).toLowerCase();
  const allowedMimes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'image/png',
    'image/jpeg',
  ];

  if (allowedExts.includes(ext) || allowedMimes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Unsupported file type. Allowed: PDF, DOC, DOCX, PNG, JPG, JPEG'), false);
  }
};

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB Max
  fileFilter,
});

/**
 * POST /api/media/upload-certificate
 * Requirement 3: SC Caste Certificate Upload
 */
router.post('/upload-certificate', (req, res) => {
  upload.single('certificate')(req, res, (err) => {
    if (err) {
      if (err instanceof multer.MulterError && err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({ error: 'File size exceeds 5 MB maximum limit' });
      }
      return res.status(400).json({ error: err.message || 'File upload failed' });
    }

    if (!req.file) {
      return res.status(400).json({ error: 'SC Caste Certificate document is required' });
    }

    const fileUrl = `/uploads/certificates/${req.file.filename}`;
    return res.json({
      message: 'SC Caste Certificate uploaded successfully',
      certificateUrl: fileUrl,
      filename: req.file.originalname,
      size: req.file.size,
    });
  });
});

/**
 * POST /api/media/stt
 * Requirements 12 & 13 & 14: NVIDIA Speech-To-Text API
 */
router.post('/stt', async (req, res) => {
  try {
    const { audioBase64, languageCode } = req.body;
    if (!audioBase64) {
      return res.status(400).json({ error: 'audioBase64 is required' });
    }

    const text = await speechToText({ audioBase64, languageCode: languageCode || 'en' });
    return res.json({ text });
  } catch (err) {
    console.error('STT endpoint error:', err);
    return res.status(500).json({ error: 'Speech recognition service error' });
  }
});

/**
 * POST /api/media/tts
 * Requirements 15 & 16 & 17: NVIDIA Text-To-Speech API
 */
router.post('/tts', async (req, res) => {
  try {
    const { text, languageCode } = req.body;
    if (!text) {
      return res.status(400).json({ error: 'text is required for Text-to-Speech' });
    }

    const audioBase64 = await textToSpeech({ text, languageCode: languageCode || 'en' });
    return res.json({ audioBase64 });
  } catch (err) {
    console.error('TTS endpoint error:', err);
    return res.status(500).json({ error: 'Text-to-speech service error' });
  }
});

module.exports = router;
