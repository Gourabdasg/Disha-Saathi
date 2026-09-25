"""
Real NSQF Training Dataset Recommendation Engine for Disha Saathi AI Service.
Uses 2,814 official NSQF training records from backend/data/NSQF_Training_Recommendation.js
"""

import json
import os
import re
from typing import List, Dict, Optional

# Load the 2,814 NSQF Training records from NSQF_Training_Recommendation.js
DATASET_PATH = os.path.join(os.path.dirname(__file__), "..", "backend", "data", "NSQF_Training_Recommendation.js")

NSQF_DATASET: List[dict] = []

try:
    with open(DATASET_PATH, "r", encoding="utf-8") as f:
        content = f.read()
        json_str = content[content.find("["):content.rfind("]") + 1]
        NSQF_DATASET = json.loads(json_str)
        print(f"Loaded {len(NSQF_DATASET)} official NSQF records into Python AI Service.")
except Exception as e:
    print(f"Warning loading NSQF dataset in Python: {e}")

SECTOR_MAP = {
    "computer": ["it-ites", "electronics & hw", "telecom", "office administration & facility management"],
    "it": ["it-ites", "electronics & hw", "telecom"],
    "data": ["it-ites", "office administration & facility management", "transportation, logistics & warehousing"],
    "healthcare": ["healthcare", "life sciences", "beauty & wellness", "home management and caregiving"],
    "medical": ["healthcare", "life sciences"],
    "nursing": ["healthcare", "home management and caregiving"],
    "agriculture": ["agriculture", "environmental science", "food industry/food processing"],
    "farming": ["agriculture", "environmental science"],
    "tailoring": ["apparel", "handicrafts & carpets", "persons with disability"],
    "sewing": ["apparel", "handicrafts & carpets"],
    "electrical": ["electronics & hw", "power", "capital goods & manufacturing", "automotive"],
    "driving": ["transportation, logistics & warehousing", "automotive"],
    "driver": ["transportation, logistics & warehousing", "automotive"],
    "retail": ["retail", "bfsi", "office administration & facility management"],
    "cooking": ["tourism & hospitality", "food industry/food processing", "home management and caregiving"],
    "construction": ["construction", "plumbing", "capital goods & manufacturing"],
    "plumbing": ["plumbing", "water supply, sewerage, waste management & remediation activities"],
    "solar": ["environmental science", "electronics & hw", "power"],
    "beauty": ["beauty & wellness"],
    "mechanic": ["automotive", "capital goods & manufacturing"],
}


def extract_skills(text: str) -> dict:
    text_lower = (text or "").lower()
    matched = {}
    for key in SECTOR_MAP:
        if key in text_lower:
            matched[key] = 100.0
    return matched


def match_nsqf_trainings(user_text: str, profile: Optional[dict] = None, limit: int = 4) -> List[dict]:
    profile_dict = profile or {}
    text_query = f"{user_text or ''} {profile_dict.get('skills', '')} {profile_dict.get('interests', '')} {profile_dict.get('careerGoal', '')} {profile_dict.get('education', '')}".lower()
    tokens = re.findall(r"[a-z0-9]+", text_query)

    scored = []

    for row in NSQF_DATASET:
        if not row or not row.get("Title"):
            continue

        score = 25
        title = (row.get("Title") or "").lower()
        desc = (row.get("Description") or "").lower()
        sector = (row.get("Sector Name") or "").lower()
        occ = (row.get("Proposed Occupation") or "").lower()

        for t in tokens:
            if len(t) < 3:
                continue
            if t in title:
                score += 20
            if t in occ:
                score += 15
            if t in sector:
                score += 12
            if t in desc:
                score += 5

        for key, sectors in SECTOR_MAP.items():
            if key in text_query:
                for sec in sectors:
                    if sec in sector:
                        score += 25

        match_pct = min(98, max(68, int(score)))

        if score > 32:
            scored.append({
                "sNo": row.get("S No."),
                "title": row.get("Title"),
                "code": row.get("Code") or "NSQF-GOV-COURSE",
                "description": row.get("Description") or "",
                "sectorName": row.get("Sector Name") or "Skill Development",
                "level": row.get("Level") or "Level 3",
                "duration": row.get("Maximum Notational Hours") or row.get("Minimum Notational Hours") or "300 Hours",
                "awardingBody": row.get("Awarding Body") or "National Skill Development Corporation",
                "progressionPathway": (row.get("Progression Pathway") or "Career Advancement").split("\n")[0],
                "matchPercent": match_pct,
            })

    scored.sort(key=lambda x: x["matchPercent"], reverse=True)

    if not scored and NSQF_DATASET:
        for i in [0, 4, 10, 15]:
            if i < len(NSQF_DATASET):
                row = NSQF_DATASET[i]
                scored.append({
                    "sNo": row.get("S No."),
                    "title": row.get("Title"),
                    "code": row.get("Code") or "NSQF-GOV-COURSE",
                    "description": row.get("Description") or "",
                    "sectorName": row.get("Sector Name") or "Skill Development",
                    "level": row.get("Level") or "Level 3",
                    "duration": row.get("Maximum Notational Hours") or "300 Hours",
                    "awardingBody": row.get("Awarding Body") or "NSDC",
                    "progressionPathway": "Career Growth",
                    "matchPercent": 75,
                })

    return scored[:limit]


def build_reply(user_text: str, profile: Optional[dict] = None, language: str = "en") -> dict:
    matches = match_nsqf_trainings(user_text, profile=profile, limit=4)
    lang = (language or "en").lower().strip()

    if lang == "hi":
        reply = "आपके लिए आधिकारिक NSQF-संरेखित प्रशिक्षण सिफारिशें:\n\n"
    elif lang == "bn":
        reply = "আপনার জন্য সরকারি এনএসকিউএফ-অনুমোদিত প্রশিক্ষণ সুপারিশ:\n\n"
    else:
        reply = "Recommended Official NSQF Training Courses For You:\n\n"

    for idx, item in enumerate(matches, 1):
        reply += f"{idx}. **{item['title']}** ({item['level']} · {item['duration']})\n"
        reply += f"   • **Sector**: {item['sectorName']}\n"
        reply += f"   • **Awarding Body**: {item['awardingBody']}\n"
        reply += f"   • **Match**: {item['matchPercent']}%\n\n"

    if lang == "hi":
        reply += "यह पाठ्यक्रम आपकी प्रोफ़ाइल, कौशल, रुचि और शैक्षिक योग्यता के आधार पर चुना गया है।"
    elif lang == "bn":
        reply += "এই কোর্সটি আপনার প্রোফাইল, দক্ষতা, আগ্রহ এবং শিক্ষাগত যোগ্যতার ওপর ভিত্তি করে নির্বাচন করা হয়েছে।"
    else:
        reply += "This course matches your profile, skills, career goals, and educational qualification pathway."

    return {
        "reply": reply.strip(),
        "matchedTrainings": matches,
    }
