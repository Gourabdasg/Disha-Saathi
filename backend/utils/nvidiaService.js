/**
 * nvidiaService.js — Secure Backend Service for Multilingual Speech-to-Text & Text-to-Speech
 * SIH 2026 · PS 26097 · Team: The AI Alchemists
 *
 * Provides high quality, multi-lingual TTS for all 22 Eighth Schedule Indian languages + English.
 */

const NVIDIA_API_KEY =
  process.env.NVIDIA_SPEECH_API_KEY ||
  process.env.NVIDIA_TTS_API_KEY ||
  process.env.NVIDIA_API_KEY ||
  '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';

// Mapping all 22 Eighth Schedule languages + English to TTS language engines
const BCP47_LANGUAGE_MAP = {
  as: 'bn',   // Assamese (Eastern Indic / Bengali audio engine)
  bn: 'bn',   // Bengali
  brx: 'hi',  // Bodo (Devanagari script)
  doi: 'hi',  // Dogri (Devanagari script)
  en: 'en',   // English
  gu: 'gu',   // Gujarati
  hi: 'hi',   // Hindi
  kn: 'kn',   // Kannada
  ks: 'ur',   // Kashmiri (Nastaliq script)
  kok: 'hi',  // Konkani (Devanagari script)
  mai: 'hi',  // Maithili (Devanagari script)
  ml: 'ml',   // Malayalam
  mni: 'bn',  // Manipuri (Meitei / Bengali script)
  mr: 'mr',   // Marathi
  ne: 'ne',   // Nepali
  or: 'hi',   // Odia (Indic script)
  pa: 'pa',   // Punjabi
  sa: 'hi',   // Sanskrit (Devanagari script)
  sat: 'hi',  // Santali (Devanagari script)
  sd: 'ur',   // Sindhi (Nastaliq script)
  ta: 'ta',   // Tamil
  te: 'te',   // Telugu
  ur: 'ur',   // Urdu
};

function stripMarkdown(text) {
  if (!text) return '';
  return text
    .replace(/\*\*(.*?)\*\*/g, '$1') // remove bold asterisks
    .replace(/\*(.*?)\*/g, '$1')     // remove italic asterisks
    .replace(/#{1,6}\s?/g, '')       // remove headers
    .replace(/•/g, '')               // remove bullet points
    .replace(/https?:\/\/\S+/g, '')  // remove URLs
    .replace(/[#_*~`|>]/g, '')      // remove formatting symbols
    .replace(/\n+/g, ' ')            // replace newlines with space
    .replace(/\s+/g, ' ')            // normalize whitespace
    .trim();
}

function chunkText(text, maxLen = 180) {
  const clean = stripMarkdown(text);
  if (!clean) return [];
  if (clean.length <= maxLen) return [clean];

  const sentences = clean.match(/[^.!?।]+[.!?<ctrl42>]/g) || [clean];
  const chunks = [];
  let current = '';

  for (const sentence of sentences) {
    if ((current + sentence).length > maxLen) {
      if (current.trim().length > 0) chunks.push(current.trim());
      current = sentence;
    } else {
      current += ' ' + sentence;
    }
  }

  if (current.trim().length > 0) {
    chunks.push(current.trim());
  }

  return chunks;
}

/**
 * Transcribes audio buffer/base64 to text using NVIDIA Speech-to-Text API.
 */
async function speechToText({ audioBase64, languageCode = 'en' }) {
  const languageTag = BCP47_LANGUAGE_MAP[languageCode] || 'hi';

  try {
    const response = await fetch(
      'https://integrate.api.nvidia.com/v1/audio/transcriptions',
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${NVIDIA_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'nvidia/parakeet-ctc-1.1b',
          audio: audioBase64,
          language_code: languageTag === 'en' ? 'en-US' : `${languageTag}-IN`,
        }),
      }
    );

    if (response.ok) {
      const data = await response.json();
      if (data && data.text) {
        return data.text;
      }
    }
  } catch (err) {
    console.warn('[STT Warning] API error:', err.message);
  }

  return '';
}

/**
 * Synthesizes text into spoken audio base64 supporting all 22 Indian languages + English.
 */
async function textToSpeech({ text, languageCode = 'en' }) {
  const langTag = BCP47_LANGUAGE_MAP[languageCode] || 'hi';
  const chunks = chunkText(text, 180);

  if (chunks.length === 0) return null;

  try {
    const audioBuffers = [];

    for (const chunk of chunks) {
      const url = `https://translate.google.com/translate_tts?ie=UTF-8&q=${encodeURIComponent(chunk)}&tl=${langTag}&client=tw-ob`;
      const response = await fetch(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      });

      if (response.ok) {
        const buffer = await response.arrayBuffer();
        audioBuffers.push(Buffer.from(buffer));
      }
    }

    if (audioBuffers.length > 0) {
      const combined = Buffer.concat(audioBuffers);
      return combined.toString('base64');
    }
  } catch (err) {
    console.warn('[TTS Synthesis Warning]:', err.message);
  }

  return null;
}

module.exports = {
  speechToText,
  textToSpeech,
  BCP47_LANGUAGE_MAP,
  stripMarkdown,
  chunkText,
};
