"""
Real NLP-based skill/occupation extraction for Disha Saathi's AI Skill
Assistant (SIH 2026, PS 26097).

This uses genuine NLP techniques — tokenization, lemmatization, and
part-of-speech filtering via spaCy — plus fuzzy string matching (rapidfuzz)
as a typo-tolerant fallback. It is meaningfully more robust than plain
substring/keyword matching: it correctly handles typos ("farmin" ->
Agriculture), inflected forms ("cooking"/"cooked"/"cook"), and free-form
phrasing ("I am a driver by profession" -> Driving).

IMPORTANT SCOPE NOTE: this pipeline understands ENGLISH only. spaCy's small
English model (en_core_web_sm) has no knowledge of Hindi, Bengali, or other
Indian languages. For multilingual support, the dictionary-based matching
already implemented in the Node.js backend (backend/data/skillsDataset.js)
is the practical approach for this project — a true multilingual NLP model
is a much larger, separate undertaking (a large multilingual transformer,
which needs significant compute to run) and is out of scope here. Treat
this service as an ENGLISH-understanding upgrade layered alongside the
existing Hindi/Bengali dictionary matching, not a replacement for it.
"""

try:
    import spacy
    _nlp = spacy.load("en_core_web_sm")
except Exception:
    _nlp = None

from rapidfuzz import process, fuzz

# Canonical skill/occupation categories, matching backend/data/skillsDataset.js
# so results line up with the same NSQF training recommendations there.
SKILL_SYNONYMS = {
    "tailor": "Tailoring", "tailoring": "Tailoring", "stitch": "Tailoring",
    "stitching": "Tailoring", "sew": "Tailoring", "sewing": "Tailoring",

    "farm": "Agriculture", "farming": "Agriculture", "agriculture": "Agriculture",
    "crop": "Agriculture", "cultivate": "Agriculture", "cultivation": "Agriculture",

    "fish": "Fisheries", "fishing": "Fisheries", "fishery": "Fisheries",

    "computer": "Computer Operation", "typing": "Computer Operation", "type": "Computer Operation",

    "drive": "Driving", "driving": "Driving", "driver": "Driving",

    "electrical": "Electrical Work", "electrician": "Electrical Work",
    "wire": "Electrical Work", "wiring": "Electrical Work",

    "cook": "Cooking", "cooking": "Cooking", "chef": "Cooking",

    "sell": "Sales", "sale": "Sales", "sales": "Sales", "selling": "Sales", "vendor": "Sales",

    "handicraft": "Handicrafts", "craft": "Handicrafts",

    "communicate": "Communication", "communication": "Communication",

    "construction": "Construction", "mason": "Construction", "build": "Construction",
    "labour": "Construction", "labor": "Construction",

    "packaging": "Food Processing", "processing": "Food Processing",
}
_SYNONYM_KEYS = list(SKILL_SYNONYMS.keys())

# Same NSQF training dataset shape as backend/data/skillsDataset.js, so a
# skill match here maps to the same recommended courses across both services.
OCCUPATION_TRAININGS = {
    "Agriculture": ["food-processing-technician", "retail-sales-associate"],
    "Fisheries": ["food-processing-technician", "retail-sales-associate"],
    "Tailoring": ["apparel-manufacturing", "retail-sales-associate"],
    "Computer Operation": ["digital-office-assistant", "data-entry-operator"],
    "Driving": ["logistics-associate"],
    "Electrical Work": ["electrician-technician"],
    "Cooking": ["food-processing-technician"],
    "Sales": ["retail-sales-associate", "customer-service-associate"],
    "Handicrafts": ["apparel-manufacturing"],
    "Construction": ["electrician-technician"],
    "Food Processing": ["food-processing-technician"],
}

TRAININGS = {
    "digital-office-assistant": {
        "title": "Digital Office Assistant", "nsqfLevel": 3, "duration": "3 Months",
        "employmentOpportunities": "Office Assistant, Data Entry Clerk (₹12,000-18,000/month)",
    },
    "data-entry-operator": {
        "title": "Data Entry Operator", "nsqfLevel": 2, "duration": "2 Months",
        "employmentOpportunities": "Data entry roles, BPOs (₹10,000-15,000/month)",
    },
    "retail-sales-associate": {
        "title": "Retail Sales Associate", "nsqfLevel": 2, "duration": "6 Weeks",
        "employmentOpportunities": "Retail stores, supermarkets (₹9,000-14,000/month)",
    },
    "customer-service-associate": {
        "title": "Customer Service Associate", "nsqfLevel": 3, "duration": "3 Months",
        "employmentOpportunities": "Call centers, support roles (₹11,000-16,000/month)",
    },
    "food-processing-technician": {
        "title": "Food Processing Technician", "nsqfLevel": 3, "duration": "2 Months",
        "employmentOpportunities": "Food processing units, agri-business (₹9,000-14,000/month)",
    },
    "apparel-manufacturing": {
        "title": "Apparel Manufacturing (Tailoring)", "nsqfLevel": 2, "duration": "2 Months",
        "employmentOpportunities": "Garment units, self-employment (₹8,000-13,000/month)",
    },
    "electrician-technician": {
        "title": "Electrician (Domestic & Industrial)", "nsqfLevel": 3, "duration": "3 Months",
        "employmentOpportunities": "Electrical contractors, self-employment (₹12,000-20,000/month)",
    },
    "logistics-associate": {
        "title": "Logistics Associate (incl. Driving)", "nsqfLevel": 2, "duration": "1 Month",
        "employmentOpportunities": "Delivery services, logistics companies (₹10,000-16,000/month)",
    },
}

_VALID_POS = {"NOUN", "VERB", "PROPN", "ADJ"}


def extract_skills(text: str, fuzzy_threshold: int = 85) -> dict:
    matched: dict[str, float] = {}
    if not text:
        return matched

    if _nlp is not None:
        doc = _nlp(text)
        for tok in doc:
            if not tok.is_alpha or tok.is_stop or len(tok.text) < 3:
                continue
            if tok.pos_ not in _VALID_POS:
                continue

            lemma = tok.lemma_.lower()
            raw = tok.text.lower()

            if lemma in SKILL_SYNONYMS:
                canonical = SKILL_SYNONYMS[lemma]
                matched[canonical] = 100.0
                continue
            if raw in SKILL_SYNONYMS:
                canonical = SKILL_SYNONYMS[raw]
                matched[canonical] = 100.0
                continue

            best = process.extractOne(raw, _SYNONYM_KEYS, scorer=fuzz.ratio)
            if best and best[1] >= fuzzy_threshold:
                canonical = SKILL_SYNONYMS[best[0]]
                matched[canonical] = max(matched.get(canonical, 0), best[1])
    else:
        # Fallback keyword tokenization when spacy model is not downloaded
        words = [w.lower().strip(".,!?") for w in text.split() if len(w) >= 3]
        for w in words:
            if w in SKILL_SYNONYMS:
                canonical = SKILL_SYNONYMS[w]
                matched[canonical] = 100.0
            else:
                best = process.extractOne(w, _SYNONYM_KEYS, scorer=fuzz.ratio)
                if best and best[1] >= fuzzy_threshold:
                    canonical = SKILL_SYNONYMS[best[0]]
                    matched[canonical] = max(matched.get(canonical, 0), best[1])

    return matched


def build_reply(detected_skills: dict) -> dict:
    """Mirrors backend/routes/chat.js's buildReply(), for parity across both services."""
    if not detected_skills:
        return {
            "reply": (
                "I didn't catch a specific skill in that — could you tell me what work you do? "
                "For example: farming, tailoring, driving, cooking, or computer work."
            ),
            "matchedTrainings": [],
        }

    training_keys = set()
    for skill in detected_skills:
        training_keys.update(OCCUPATION_TRAININGS.get(skill, []))

    matched_trainings = [TRAININGS[k] for k in training_keys if k in TRAININGS]

    skill_list = ", ".join(detected_skills.keys())
    reply = f"Got it — I noticed you mentioned: {skill_list}. "
    if matched_trainings:
        reply += "Here are NSQF-aligned training options that could help:\n\n"
        for t in matched_trainings:
            reply += f"• {t['title']} (NSQF Level {t['nsqfLevel']}, {t['duration']}) — {t['employmentOpportunities']}\n"
    else:
        reply += "I don't have a specific training match for that yet in this demo dataset."

    return {"reply": reply.strip(), "matchedTrainings": matched_trainings}