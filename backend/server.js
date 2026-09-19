/**
 * Disha Saathi — Node.js + Express backend
 * SIH 2026 · PS 26097 · Team: The AI Alchemists
 */
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const path = require('path');

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
app.use(express.json());

// Serve uploaded certificates securely
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

const PORT = process.env.PORT || 4000;
const HOST = '0.0.0.0';
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/disha_saathi';

app.get('/health', (req, res) => res.json({ status: 'ok', service: 'disha-saathi-backend' }));

app.use('/api/auth', authRoutes);
app.use('/api/beneficiary', beneficiaryRoutes);
app.use('/api/recommendations', recommendationRoutes);
app.use('/api/training', trainingRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/media', mediaRoutes);

// Start server IMMEDIATELY so port 4000 is open without waiting for DB
app.listen(PORT, HOST, () => console.log(`Disha Saathi backend running on ${HOST}:${PORT}`));

// Connect to MongoDB in background
mongoose
  .connect(MONGO_URI, { serverSelectionTimeoutMS: 5000, connectTimeoutMS: 5000 })
  .then(() => {
    console.log('MongoDB connected');
  })
  .catch((err) => {
    console.error('MongoDB connection failed, running in demo mode (no DB):', err.message);
  });
