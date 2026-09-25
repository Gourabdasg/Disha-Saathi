const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { handleOnboardingMessage, resetOnboarding } = require('../controllers/onboardingController');
const { buildNsqfChatResponse } = require('../utils/nsqfMatcher');

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';

// In-memory fallback message store for offline / demo mode
// Map<mobile, Map<sessionId, Array<msg>>>
const inMemorySessions = new Map();

function getInMemoryList(mobile, sessionId) {
  const key = mobile || 'anonymous';
  const sid = sessionId || 'default';
  if (!inMemorySessions.has(key)) inMemorySessions.set(key, new Map());
  const userMap = inMemorySessions.get(key);
  if (!userMap.has(sid)) userMap.set(sid, []);
  return userMap.get(sid);
}

async function saveMessage(mobile, sender, text, sessionId = 'default') {
  const key = mobile || 'anonymous';
  const sid = sessionId || 'default';
  const msg = { mobile: key, sessionId: sid, sender, text, createdAt: new Date() };

  getInMemoryList(key, sid).push(msg);

  try {
    await query(
      `INSERT INTO chat_messages (mobile, session_id, sender, text) VALUES ($1, $2, $3, $4);`,
      [key, sid, sender, text]
    );
  } catch (e) {
    console.warn('ChatMessage PostgreSQL save warning:', e.message);
  }
}

async function getHistory(mobile, sessionId = 'default') {
  const key = mobile || 'anonymous';
  const sid = sessionId || 'default';
  try {
    const res = await query(
      `SELECT mobile, session_id AS "sessionId", sender, text, created_at AS "createdAt" FROM chat_messages WHERE mobile = $1 AND session_id = $2 ORDER BY created_at ASC;`,
      [key, sid]
    );
    if (res.rows && res.rows.length > 0) return res.rows;
  } catch (e) {
    console.warn('ChatMessage PostgreSQL find warning:', e.message);
  }
  return getInMemoryList(key, sid);
}

async function getSessionsList(mobile) {
  const key = mobile || 'anonymous';
  try {
    const res = await query(
      `SELECT session_id AS "sessionId",
              MIN(created_at) AS "createdAt",
              MAX(created_at) AS "updatedAt",
              COUNT(*) AS "messageCount",
              (SELECT text FROM chat_messages m2 WHERE m2.mobile = m1.mobile AND m2.session_id = m1.session_id AND m2.sender = 'user' ORDER BY created_at ASC LIMIT 1) AS "firstUserMsg",
              (SELECT text FROM chat_messages m3 WHERE m3.mobile = m1.mobile AND m3.session_id = m1.session_id ORDER BY created_at DESC LIMIT 1) AS "lastMessage"
       FROM chat_messages m1
       WHERE mobile = $1
       GROUP BY mobile, session_id
       ORDER BY MAX(created_at) DESC;`,
      [key]
    );

    if (res.rows && res.rows.length > 0) {
      return res.rows.map((row) => {
        let title = row.firstUserMsg || 'AI Skill Assessment';
        if (title.length > 35) title = title.substring(0, 32) + '...';
        return {
          sessionId: row.sessionId,
          title: title,
          lastMessage: row.lastMessage || 'Conversation started',
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          messageCount: parseInt(row.messageCount, 10) || 0,
        };
      });
    }
  } catch (e) {
    console.warn('Chat sessions list PostgreSQL warning:', e.message);
  }

  // Fallback to in-memory sessions
  if (inMemorySessions.has(key)) {
    const userMap = inMemorySessions.get(key);
    const list = [];
    for (const [sid, msgs] of userMap.entries()) {
      if (!msgs || msgs.length === 0) continue;
      const firstUser = msgs.find((m) => m.sender === 'user');
      let title = firstUser ? firstUser.text : 'AI Skill Assessment';
      if (title.length > 35) title = title.substring(0, 32) + '...';
      const lastMsg = msgs[msgs.length - 1].text;
      list.push({
        sessionId: sid,
        title,
        lastMessage: lastMsg,
        createdAt: msgs[0].createdAt,
        updatedAt: msgs[msgs.length - 1].createdAt,
        messageCount: msgs.length,
      });
    }
    return list;
  }

  return [];
}

async function clearHistory(mobile, sessionId = 'default') {
  const key = mobile || 'anonymous';
  const sid = sessionId || 'default';

  if (inMemorySessions.has(key)) {
    inMemorySessions.get(key).delete(sid);
  }

  try {
    await query(`DELETE FROM chat_messages WHERE mobile = $1 AND session_id = $2;`, [key, sid]);
  } catch (e) {
    console.warn('ChatMessage PostgreSQL clear warning:', e.message);
  }
}

async function deleteSession(mobile, sessionId) {
  const key = mobile || 'anonymous';
  const sid = sessionId || 'default';

  if (inMemorySessions.has(key)) {
    inMemorySessions.get(key).delete(sid);
  }

  try {
    await query(`DELETE FROM chat_messages WHERE mobile = $1 AND session_id = $2;`, [key, sid]);
  } catch (e) {
    console.warn('ChatMessage PostgreSQL delete session warning:', e.message);
  }
}

async function handleChatPost(req, res) {
  try {
    const { mobile, text, language, sessionId } = req.body;

    if (!text) {
      return res.status(400).json({ error: 'text is required' });
    }

    const userMobile = mobile || 'anonymous';
    const sid = sessionId || 'default';
    const langCode = (language || 'en').toLowerCase().trim();

    // Save user message in specific session
    await saveMessage(userMobile, 'user', text, sid);

    // Step 1: Onboarding flow in user's selected language
    const onboarding = await handleOnboardingMessage(userMobile, text, langCode, null);

    if (onboarding.handled) {
      await saveMessage(userMobile, 'bot', onboarding.reply, sid);
      return res.json({
        reply: onboarding.reply,
        onboardingComplete: onboarding.profileComplete,
        sessionId: sid,
      });
    }

    // Step 2: Dynamic NSQF Dataset Training Recommendations Engine
    const reply = await generateAssistantReply(text, onboarding.profile, langCode);
    await saveMessage(userMobile, 'bot', reply, sid);
    return res.json({ reply, onboardingComplete: true, sessionId: sid });
  } catch (err) {
    console.error('Chat route error:', err);
    return res.status(500).json({ error: 'Something went wrong. Please try again.' });
  }
}

async function handleChatGet(req, res) {
  try {
    const mobile = req.params.mobile || 'anonymous';
    const sessionId = req.query.sessionId || req.query.session_id || 'default';
    const messages = await getHistory(mobile, sessionId);
    return res.json(messages);
  } catch (err) {
    console.error('Fetch chat history error:', err);
    return res.status(500).json({ error: 'Could not fetch chat history' });
  }
}

async function handleGetSessions(req, res) {
  try {
    const mobile = req.params.mobile || 'anonymous';
    const sessions = await getSessionsList(mobile);
    return res.json(sessions);
  } catch (err) {
    console.error('Fetch sessions error:', err);
    return res.status(500).json({ error: 'Could not fetch chat sessions' });
  }
}

async function handleDeleteSession(req, res) {
  try {
    const mobile = req.params.mobile || 'anonymous';
    const sessionId = req.params.sessionId || req.body.sessionId;
    await deleteSession(mobile, sessionId);
    return res.json({ message: 'Session deleted successfully', mobile, sessionId });
  } catch (err) {
    console.error('Delete session error:', err);
    return res.status(500).json({ error: 'Could not delete session' });
  }
}

async function handleChatClear(req, res) {
  try {
    const { mobile, sessionId } = req.body;
    const userMobile = mobile || req.params.mobile || 'anonymous';
    const sid = sessionId || 'default';
    await clearHistory(userMobile, sid);
    return res.json({ message: 'Chat history cleared successfully', mobile: userMobile, sessionId: sid });
  } catch (err) {
    console.error('Clear chat error:', err);
    return res.status(500).json({ error: 'Could not clear chat history' });
  }
}

async function handleChatRestart(req, res) {
  try {
    const { mobile, sessionId } = req.body;
    const userMobile = mobile || 'anonymous';
    const sid = sessionId || 'default';
    await clearHistory(userMobile, sid);
    await resetOnboarding(userMobile);
    return res.json({ message: 'Chat restarted successfully', mobile: userMobile, sessionId: sid });
  } catch (err) {
    console.error('Restart chat error:', err);
    return res.status(500).json({ error: 'Could not restart chat' });
  }
}

// Route Aliases
router.post('/', handleChatPost);
router.post('/message', handleChatPost);

router.get('/sessions/:mobile', handleGetSessions);
router.get('/:mobile', handleChatGet);
router.get('/history/:mobile', handleChatGet);

router.delete('/session/:mobile/:sessionId', handleDeleteSession);
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
