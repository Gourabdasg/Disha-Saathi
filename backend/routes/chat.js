const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

const ChatMessage = require('../models/ChatMessage');
const { handleOnboardingMessage, resetOnboarding } = require('../controllers/onboardingController');

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';

// In-memory fallback message store for offline / demo mode
const inMemoryMessages = new Map();

async function saveMessage(mobile, sender, text) {
  const key = mobile || 'anonymous';
  const msg = { mobile: key, sender, text, createdAt: new Date() };

  if (!inMemoryMessages.has(key)) {
    inMemoryMessages.set(key, []);
  }
  inMemoryMessages.get(key).push(msg);

  if (mongoose.connection.readyState === 1) {
    try {
      await ChatMessage.create({ mobile: key, sender, text });
    } catch (e) {
      console.warn('ChatMessage DB save failed:', e.message);
    }
  }
}

async function getHistory(mobile) {
  const key = mobile || 'anonymous';
  if (mongoose.connection.readyState === 1) {
    try {
      const messages = await ChatMessage.find({ mobile: key }).sort({ createdAt: 1 });
      if (messages && messages.length > 0) return messages;
    } catch (e) {
      console.warn('ChatMessage DB find failed:', e.message);
    }
  }
  return inMemoryMessages.get(key) || [];
}

async function clearHistory(mobile) {
  const key = mobile || 'anonymous';
  inMemoryMessages.delete(key);
  if (mongoose.connection.readyState === 1) {
    try {
      await ChatMessage.deleteMany({ mobile: key });
    } catch (e) {
      console.warn('ChatMessage DB clear failed:', e.message);
    }
  }
}

async function handleChatPost(req, res) {
  try {
    const { mobile, text } = req.body;

    if (!text) {
      return res.status(400).json({ error: 'text is required' });
    }

    const userMobile = mobile || 'anonymous';

    // Save user message
    await saveMessage(userMobile, 'user', text);

    // Step 1: Onboarding flow
    const onboarding = await handleOnboardingMessage(userMobile, text, null);

    if (onboarding.handled) {
      await saveMessage(userMobile, 'bot', onboarding.reply);
      return res.json({
        reply: onboarding.reply,
        onboardingComplete: onboarding.profileComplete,
      });
    }

    // Step 2: Call Python FastAPI AI Service for NLP skill matching
    const reply = await generateAssistantReply(text, onboarding.profile);
    await saveMessage(userMobile, 'bot', reply);
    return res.json({ reply, onboardingComplete: true });
  } catch (err) {
    console.error('Chat route error:', err);
    return res.status(500).json({ error: 'Something went wrong. Please try again.' });
  }
}

async function handleChatGet(req, res) {
  try {
    const mobile = req.params.mobile || 'anonymous';
    const messages = await getHistory(mobile);
    return res.json(messages);
  } catch (err) {
    console.error('Fetch chat history error:', err);
    return res.status(500).json({ error: 'Could not fetch chat history' });
  }
}

async function handleChatClear(req, res) {
  try {
    const { mobile } = req.body;
    const userMobile = mobile || req.params.mobile || 'anonymous';
    await clearHistory(userMobile);
    return res.json({ message: 'Chat history cleared successfully', mobile: userMobile });
  } catch (err) {
    console.error('Clear chat error:', err);
    return res.status(500).json({ error: 'Could not clear chat history' });
  }
}

async function handleChatRestart(req, res) {
  try {
    const { mobile } = req.body;
    const userMobile = mobile || 'anonymous';
    await clearHistory(userMobile);
    await resetOnboarding(userMobile);
    return res.json({ message: 'Chat restarted successfully', mobile: userMobile });
  } catch (err) {
    console.error('Restart chat error:', err);
    return res.status(500).json({ error: 'Could not restart chat' });
  }
}

// Route Aliases
router.post('/', handleChatPost);
router.post('/message', handleChatPost);

router.get('/:mobile', handleChatGet);
router.get('/history/:mobile', handleChatGet);

router.delete('/history/:mobile', handleChatClear);
router.post('/clear', handleChatClear);
router.post('/restart', handleChatRestart);

async function generateAssistantReply(userText, profile) {
  try {
    const response = await fetch(`${AI_SERVICE_URL}/ai/skill-match`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text: userText }),
    });

    if (response.ok) {
      const data = await response.json();
      if (data && data.reply) {
        return data.reply;
      }
    }
  } catch (err) {
    console.warn('Python AI Service call warning (using fallback):', err.message);
  }

  const name = profile && profile.name ? profile.name : 'there';
  return `Got it, ${name}! I am your AI Skill Assistant. How else can I assist you with your career or skill development?`;
}

module.exports = router;
