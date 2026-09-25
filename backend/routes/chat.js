const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { handleOnboardingMessage, resetOnboarding } = require('../controllers/onboardingController');

const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';

// In-memory fallback message store for offline / demo mode
const inMemoryMessages = new Map();

const multilingualReplies = {
  hi: 'नमस्ते! मैं आपका दिशा साथी एआई सहायक हूं। मैं आपकी आजीविका और कौशल विकास में कैसे मदद कर सकता हूं?',
  bn: 'নমস্কার! আমি আপনার দিশা সাথী এআই সহকারী। আমি কিভাবে আপনার জীবিকা ও দক্ষতা বৃদ্ধিতে সাহায্য করতে পারি?',
  mr: 'नमस्कार! मी तुमचा दिशा साथी एआय सहाय्यक आहे. मी तुमच्या उपजीविका आणि कौशल्य विकासात कशी मदत करू शकतो?',
  te: 'నమస్కారం! నేను మీ దిశా సాథీ AI సహాయకుడిని. మీ జీవనోపాధి మరియు నైపుణ్యాభివృద్ధికి నేను ఎలా సహాయపడగలను?',
  ta: 'வணக்கம்! நான் உங்கள் திஷா சாதி AI உதவியாளர். உங்கள் வாழ்வாதாரம் மற்றும் திறன் வளர்ச்சிக்கு நான் எவ்வாறு உதவ முடியும்?',
  ur: 'سلام! میں آپ کا دیشا ساتھی اے آئی اسسٹنٹ ہوں۔ میں آپ کے روزگار اور مہارت کی ترقی میں کیسے مدد کر سکتا ہوں؟',
  pa: 'ਸਤਿ ਸ਼੍ਰੀ ਅਕਾਲ! ਮੈਂ ਤੁਹਾਡਾ ਦਿਸ਼ਾ ਸਾਥੀ ਏਆਈ ਸਹਾਇਕ ਹਾਂ। ਮੈਂ ਤੁਹਾਡੀ ਰੋਜ਼ੀ-ਰੋਟੀ ਅਤੇ ਹੁਨਰ ਵਿਕਾਸ ਵਿੱਚ ਕਿਵੇਂ ਮਦਦ ਕਰ ਸਕਦਾ ਹਾਂ؟',
  gu: 'નમસ્તે! હું તમારો દિશા સાથી AI સહાયક છું. હું તમારી આજીવિકા અને કૌશલ્ય વિકાસમાં કેવી રીતે મદદ કરી શકું?',
  kn: 'ನಮಸ್ಕಾರ! ನಾನು ನಿಮ್ಮ ದಿಶಾ ಸಾಥಿ AI ಸಹಾಯಕ. ನಿಮ್ಮ ಜೀವ‌ನೋಪಾಯ ಮತ್ತು ಕೌಶಲ್ಯ ಅಭಿವೃದ್ಧಿಗೆ ನಾನು ಹೇಗೆ ಸಹಾಯ ಮಾಡಬಲ್ಲೆನು?',
  or: 'ନମସ୍କାର! ମୁଁ ଆପଣଙ୍କର ଦିଶା ସାଥୀ AI ସହାୟକ | ମୁଁ ଆପଣଙ୍କର ଜୀବିକା ଏବଂ ଦକ୍ଷତା ବିକାଶରେ କିପରି ସାହାଯ୍ୟ କରିପାରିବି?',
  ml: 'നമസ്കാരം! ഞാൻ നിങ്ങളുടെ ദിശ സാഥി AI അസിസ്റ്റൻറാണ്. നിങ്ങളുടെ ജീവനോപാധിയും നൈപുണ്യ വികസനവും മെച്ചപ്പെടുത്താൻ എനിക്ക് എങ്ങനെ സഹായിക്കാനാകും?',
  en: 'Hello! I am your Disha Saathi AI Assistant. How can I assist you with your livelihood and skill development today?',
};

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

    // Step 2: Call Python FastAPI AI Service or Multilingual Assistant for NLP skill matching
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
      body: JSON.stringify({ text: userText, language: langCode }),
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

  if (multilingualReplies[langCode]) {
    return multilingualReplies[langCode];
  }

  const name = profile && profile.name ? profile.name : 'there';
  return `Got it, ${name}! I am your AI Skill Assistant. How else can I assist you with your career or skill development?`;
}

module.exports = router;
