/**
 * Disha Saathi — Node.js + Express backend
 * SIH 2026 · PS 26097 · Team: The AI Alchemists
 */
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const { initDb } = require('./db');

// Prevent unexpected process crashes on unhandled errors
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err.message);
});
process.on('unhandledRejection', (reason) => {
  console.error('Unhandled Rejection:', reason);
});

const authRoutes = require('./routes/auth');
const beneficiaryRoutes = require('./routes/beneficiary');
const recommendationRoutes = require('./routes/recommendations');
const trainingRoutes = require('./routes/training');
const chatRoutes = require('./routes/chat');
const mediaRoutes = require('./routes/media');

const app = express();
app.use(cors());

// Increase JSON and URL-encoded body limits to 50MB for profile photo and certificate uploads
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Serve uploaded certificates securely
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const PORT = process.env.PORT || 4000;
const HOST = '0.0.0.0';

app.get('/health', (req, res) => res.json({ status: 'ok', service: 'disha-saathi-backend' }));

app.use('/api/auth', authRoutes);
app.use('/api/beneficiary', beneficiaryRoutes);
app.use('/api/recommendations', recommendationRoutes);
app.use('/api/training', trainingRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/media', mediaRoutes);

// Start server IMMEDIATELY so port 4000 is open
app.listen(PORT, HOST, () => console.log(`Disha Saathi backend running on ${HOST}:${PORT}`));

// Initialize PostgreSQL tables in background
initDb();
