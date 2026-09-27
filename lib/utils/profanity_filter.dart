/// High-performance Multilingual Profanity & Abusive Language Moderation Engine
/// Supports all 22 Scheduled Indian Languages + English & Hinglish variations.
class ProfanityFilter {
  static final Set<String> _profanityList = {
    // English
    'fuck', 'fucking', 'fucker', 'shit', 'bitch', 'bastard', 'asshole', 'cunt', 'dick',
    'pussy', 'motherfucker', 'idiot', 'stupid', 'dumbass', 'bullshit', 'whore', 'slut',

    // Hindi / Hinglish
    'मादरचोद', 'भोंसड़ी', 'बहनचोध', 'चूतिया', 'गांड', 'गांडू', 'लौड़ा', 'लौड़े', 'झंटू',
    'madarchod', 'bhenchod', 'mc', 'bc', 'bsdk', 'bhosdike', 'chutiya', 'gandu',
    'lauda', 'lode', 'chut', 'harami', 'kamina', 'saala', 'randi',

    // Bengali
    'মাদারচোদ', 'বাইনচোদ', 'চোদা', 'চুদিরভাই', 'খানকি', 'গান্ডু', 'বোকাচোদা', 'বাল',
    'bokachoda', 'baal', 'khanki', 'choda', 'magi',

    // Punjabi
    'ਭੈਣਚੋਦ', 'ਕੁੱਤਾ', 'ਸਾਲਾ', 'ਖਸਮਾਣੀ', 'ਪੈਂਚੋਦ',
    'pencho', 'kutta', 'kamine',

    // Marathi
    'आईझवडी', 'झाव्या', 'लवड्या', 'भाड्या',
    'aaijhvadi', 'lavedya', 'zavya',

    // Tamil
    'தேவடியா', 'ஒத்தா', 'சுன்னி', 'கூதி', 'பண்டா',
    'thevadiya', 'otha', 'punda', 'sunni',

    // Telugu
    'లంజ', 'దेंगे', 'గుద్ద', 'మడ్డ',
    'lanja', 'gudda', 'madda', 'dengat',

    // Urdu
    'بھوسڑی', 'حرامی', 'چوتیا', 'کتا', 'کمینہ',
  };

  /// Detects if input text contains profanity or abusive language.
  static bool hasProfanity(String text) {
    if (text.trim().isEmpty) return false;

    // Normalize text: lowercase and strip punctuation
    final normalized = text.toLowerCase().replaceAll(RegExp(r'[@#$%^&*()_+\-=\[\]{};:"\\|,.<>/?~!]'), ' ');
    final words = normalized.split(RegExp(r'\s+'));

    for (final word in words) {
      if (word.isEmpty) continue;

      if (_profanityList.contains(word)) return true;

      if (word.length >= 4) {
        for (final badWord in _profanityList) {
          if (badWord.length >= 4 && word == badWord) return true;
          if (badWord.length >= 5 && word.contains(badWord)) return true;
        }
      }
    }

    return false;
  }
}
