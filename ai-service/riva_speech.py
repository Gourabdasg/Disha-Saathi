"""
NVIDIA Riva cloud speech client for Disha Saathi.

Uses NVIDIA's NVCF-hosted Riva models (build.nvidia.com) over gRPC — the
same service your API key already has access to. Real speech recognition
and synthesis, not a local/self-hosted deployment (no GPU needed on your
side; NVIDIA's cloud does the inference).

REQUIRED setup (see .env.example):
  NVIDIA_API_KEY       - your nvapi-... key
  NVIDIA_ASR_FUNCTION_ID - which ASR model to call (see note below)
  NVIDIA_TTS_FUNCTION_ID - which TTS model to call (see note below)

IMPORTANT — about the function IDs:
Every model on build.nvidia.com has its own "function-id", shown on that
model's own page under its "API Reference" tab. The two below are the
ones I could verify from NVIDIA's own published documentation at the time
of writing:
  - ASR default: nvidia/parakeet-ctc-1_1b-asr (ENGLISH ONLY)
  - TTS default: Magpie-Multilingual (supports English AND several other
    languages including Hindi (hi-IN) for the generated VOICE OUTPUT)

For Hindi/Bengali SPEECH RECOGNITION specifically, I could not verify a
current, correct NVCF function-id for a hosted Hindi/Bengali ASR model —
NVIDIA's catalog changes over time and I don't have live access to check
it from here. Go to https://build.nvidia.com, search for a Hindi or
Bengali ASR model (e.g. search "hindi asr"), open its page, click "API
Reference", and copy the function-id shown there into your .env as
NVIDIA_ASR_FUNCTION_ID_HI (or similar) — then pass that language's
function id into transcribe() below via the `function_id` parameter.
Test it yourself before relying on it; I was not able to.
"""

import io
import os
import wave
from typing import Optional

import riva.client
from riva.client.proto.riva_audio_pb2 import AudioEncoding

NVIDIA_API_KEY = os.environ.get("NVIDIA_API_KEY", "")
DEFAULT_ASR_FUNCTION_ID = os.environ.get(
    "NVIDIA_ASR_FUNCTION_ID", "1598d209-5e27-4d3c-8079-4751568b1081"  # parakeet-ctc-1.1b-asr (English)
)
DEFAULT_TTS_FUNCTION_ID = os.environ.get(
    "NVIDIA_TTS_FUNCTION_ID", "ddacc747-1269-4fab-bfd9-8f593dead106"  # Magpie-Multilingual TTS
)

_RIVA_SERVER = "grpc.nvcf.nvidia.com:443"


def _auth(function_id: str) -> "riva.client.Auth":
    if not NVIDIA_API_KEY:
        raise RuntimeError("NVIDIA_API_KEY is not set — add it to ai-service/.env")
    return riva.client.Auth(
        uri=_RIVA_SERVER,
        use_ssl=True,
        metadata_args=[
            ["function-id", function_id],
            ["authorization", f"Bearer {NVIDIA_API_KEY}"],
        ],
    )


def transcribe(audio_bytes: bytes, language_code: str = "en-US", function_id: Optional[str] = None) -> str:
    """
    Speech-to-text. `audio_bytes` should be a 16-bit mono WAV/FLAC/OPUS file
    (exactly what the Flutter app's recorder produces — see the app-side
    integration notes). Returns the transcribed text, or raises RuntimeError
    with NVIDIA's own error message if the call fails.
    """
    auth = _auth(function_id or DEFAULT_ASR_FUNCTION_ID)
    asr_service = riva.client.ASRService(auth)
    config = riva.client.RecognitionConfig(
        language_code=language_code,
        max_alternatives=1,
        enable_automatic_punctuation=True,
    )
    try:
        response = asr_service.offline_recognize(audio_bytes, config)
    except Exception as exc:  # noqa: BLE001 - surface the real gRPC error to the caller
        raise RuntimeError(f"NVIDIA ASR request failed: {exc}") from exc

    if not response.results:
        return ""
    return response.results[0].alternatives[0].transcript


def synthesize(
    text: str,
    language_code: str = "en-US",
    voice_name: str = "Magpie-Multilingual.EN-US.Aria",
    sample_rate_hz: int = 22050,
    function_id: Optional[str] = None,
) -> bytes:
    """
    Text-to-speech. Returns a complete, playable WAV file as bytes (this
    function wraps NVIDIA's raw PCM response in a proper WAV header —
    the raw bytes alone are NOT a valid audio file on their own).
    """
    auth = _auth(function_id or DEFAULT_TTS_FUNCTION_ID)
    tts_service = riva.client.SpeechSynthesisService(auth)
    try:
        response = tts_service.synthesize(
            text=text,
            voice_name=voice_name,
            language_code=language_code,
            sample_rate_hz=sample_rate_hz,
            encoding=AudioEncoding.LINEAR_PCM,
        )
    except Exception as exc:  # noqa: BLE001
        raise RuntimeError(f"NVIDIA TTS request failed: {exc}") from exc

    return _pcm_to_wav_bytes(response.audio, sample_rate_hz)


def _pcm_to_wav_bytes(pcm_bytes: bytes, sample_rate_hz: int) -> bytes:
    """Wraps raw 16-bit mono PCM samples in a standard WAV container."""
    buffer = io.BytesIO()
    with wave.open(buffer, "wb") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(sample_rate_hz)
        wav_file.writeframes(pcm_bytes)
    return buffer.getvalue()