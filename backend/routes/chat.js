const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { handleOnboardingMessage, resetOnboarding } = require('../controllers/onboardingController');
const { buildNsqfChatResponse } = require('../utils/nsqfMatcher');

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

  try {
    await query(
      `INSERT INTO chat_messages (mobile, sender, text) VALUES ($1, $2, $3);`,
      [key, sender, text]
    );
  } catch (e) {
    console.warn('ChatMessage PostgreSQL save warning:', e.message);
  }
}

async function getHistory(mobile) {
  const key = mobile || 'anonymous';
  try {
    const res = await query(
      `SELECT mobile, sender, text, created_at AS "createdAt" FROM chat_messages WHERE mobile = $1 ORDER BY created_at ASC;`,
      [key]
    );
    if (res.rows && res.rows.length > 0) return res.rows;
  } catch (e) {
    console.warn('ChatMessage PostgreSQL find warning:', e.message);
  }
  return inMemoryMessages.get(key) || [];
}

async function clearHistory(mobile) {
  const key = mobile || 'anonymous';
  inMemoryMessages.delete(key);
  try {
    await query(`DELETE FROM chat_messages WHERE mobile = $1;`, [key]);
  } catch (e) {
    console.warn('ChatMessage PostgreSQL clear warning:', e.message);
  }
}

async function handleChatPost(req, res) {
  try {
    const { mobile, text, language } = req.body;

    if (!text) {
      return res.status(400).json({ error: 'text is required' });
    }

    const userMobile = mobile || 'anonymous';
    const langCode = (language || 'en').toLowerCase().trim();

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

    // Step 2: Dynamic NSQF Dataset Training Recommendations Engine over NSQF_Training_Recommendation.js
    const reply = await generateAssistantReply(text, onboarding.profile, langCode);
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

async function generateAssistantReply(userText, profile, language) {
  const langCode = (language || 'en').toLowerCase().trim();

  try {
    const response = await fetch(`${AI_SERVICE_URL}/ai/skill-match`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text: userText, language: langCode, profile }),
    });

    if (response.ok) {
      const data = await response.json();
      if (data && data.reply && data.reply.trim().length > 15) {
        return data.reply;
      }
    }
  } catch (err) {
    console.warn('Python AI Service call warning (using Node.js NSQF matcher):', err.message);
  }

  // Dynamic NSQF Matching Engine over NSQF_Training_Recommendation.js
  const nsqfResult = buildNsqfChatResponse(profile, userText, langCode);
  return nsqfResult.reply;
}

module.exports = router;
