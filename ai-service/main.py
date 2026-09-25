"""
Disha Saathi — Python + FastAPI AI/ML service
SIH 2026 · PS 26097 · Team: The AI Alchemists

Hosts:
  - /ai/skill-match : real NLP skill extraction over NSQF_Training_Recommendation.js
  - /ai/stt         : real speech-to-text via NVIDIA Riva cloud (see riva_speech.py)
  - /ai/tts         : real text-to-speech via NVIDIA Riva cloud (see riva_speech.py)

Run with: uvicorn main:app --reload --port 8000
Docs: http://localhost:8000/docs
"""
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.responses import Response
from pydantic import BaseModel
from typing import List, Dict, Optional
from dotenv import load_dotenv

load_dotenv()

import nlp_engine
import riva_speech

app = FastAPI(title="Disha Saathi AI Service")


class SkillMatchRequest(BaseModel):
    text: str
    language: Optional[str] = "en"
    profile: Optional[dict] = None


class SkillMatchResponse(BaseModel):
    detectedSkills: Dict[str, float]
    reply: str
    matchedTrainings: List[dict]


class TtsRequest(BaseModel):
    text: str
    language_code: str = "en-US"
    voice_name: Optional[str] = None


@app.get("/health")
def health():
    return {"status": "ok", "service": "disha-saathi-ai", "dataset_count": len(nlp_engine.NSQF_DATASET)}


@app.post("/ai/skill-match", response_model=SkillMatchResponse)
def skill_match(req: SkillMatchRequest):
    """Dynamic NSQF Training Recommendations over NSQF_Training_Recommendation.js."""
    detected = nlp_engine.extract_skills(req.text)
    result = nlp_engine.build_reply(req.text, profile=req.profile, language=req.language or "en")
    return {
        "detectedSkills": detected,
        "reply": result["reply"],
        "matchedTrainings": result["matchedTrainings"],
    }


@app.post("/ai/stt")
async def speech_to_text(
    audio: UploadFile = File(...),
    language_code: str = Form("en-US"),
):
    audio_bytes = await audio.read()
    try:
        transcript = riva_speech.transcribe(audio_bytes, language_code=language_code)
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    return {"transcript": transcript}


@app.post("/ai/tts")
def text_to_speech(req: TtsRequest):
    voice = req.voice_name or "Magpie-Multilingual.EN-US.Aria"
    try:
        wav_bytes = riva_speech.synthesize(
            text=req.text,
            language_code=req.language_code,
            voice_name=voice,
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    return Response(content=wav_bytes, media_type="audio/wav")
