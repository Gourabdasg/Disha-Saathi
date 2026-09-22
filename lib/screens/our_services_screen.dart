import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OurServicesScreen extends StatelessWidget {
  const OurServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ],
                  ),
                  const Text('Our Services', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('AI-Powered Livelihood & Skill Guidance Platform', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            // Content Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About Disha Saathi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
                        SizedBox(height: 8),
                        Text(
                          'Disha Saathi is an AI-powered, voice-first livelihood guidance platform designed to help beneficiaries discover relevant skill-development and livelihood pathways in a simple and accessible way.\n\n'
                          'Our services focus on understanding the beneficiary first and then providing personalized guidance based on their profile, skills, interests and available opportunities.',
                          style: TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _sectionHeader('OUR KEY SERVICES'),
                  const SizedBox(height: 12),

                  _serviceCard('1. Voice-Based Beneficiary Assessment', 'Interact with Disha Saathi using voice instead of complex forms.\n\nThe system can collect information such as:\n• Education\n• Existing skills\n• Work experience\n• Interests\n• Current occupation\n• Preferred work\n• Location\n• Training requirements & constraints\n\nThis information is converted into a structured livelihood profile for further analysis.'),
                  _serviceCard('2. Multilingual Voice Interaction', 'Disha Saathi supports interaction in multiple Indian languages.\n\nOur voice-first approach aims to make livelihood guidance more accessible to users who may have limited digital literacy or prefer communicating in their regional language.\n\nWhere speech recognition is uncertain, the system can use clarification or alternative input mechanisms.'),
                  _serviceCard('3. AI-Powered Livelihood Profiling', 'Disha Saathi converts conversational responses into a structured Beneficiary Livelihood Profile.\n\nThe profile captures:\nEducation + Skills + Experience + Interests + Occupation + Preferences + Constraints\n\nThis structured profile forms the foundation for personalized recommendations.'),
                  _serviceCard('4. Skill-Gap Analysis', "The system analyzes the beneficiary's existing skills against the requirements of relevant skill pathways.\n\nIt helps identify:\n• Existing capabilities\n• Relevant skill areas\n• Potential skill gaps\n• Skills requiring further training\n\nThe objective is to move toward more relevant skill guidance."),
                  _serviceCard('5. NSQF-Aligned Training Guidance', 'Disha Saathi is designed to connect identified skill gaps with relevant NSQF-aligned qualifications, job roles and training pathways using verified skill information.\n\nRecommendation flow:\nBeneficiary Profile → Skill Gap → Eligibility Check → Relevant NSQF Pathway → Training Recommendation'),
                  _serviceCard('6. Personalized Recommendation Engine', 'Combines relevant beneficiary information with training and occupational data.\n\nRecommendation factors include:\n• Skill compatibility & interest alignment\n• Education/eligibility & location\n• Skill gaps & opportunity availability\n\nBegins with transparent rule-based logic and incorporates validated outcome data for ML-based improvements.'),
                  _serviceCard('7. Local Opportunity Matching', 'Connects suitable skill pathways with relevant local opportunities:\n• Employment opportunities\n• Apprenticeships & skill-related opportunities\n• Local livelihood & self-employment pathways'),
                  _serviceCard('8. Personalized Livelihood Pathway', 'Connects the different stages of a beneficiary journey:\nCurrent Skills → Skill Gap → Training → Job/Enterprise Pathway → Local Opportunity'),
                  _serviceCard('9. Voice and Text Responses', 'Recommendations and guidance can be presented through:\n• Voice responses\n• Text responses\n• Simple visual information'),
                  _serviceCard('10. Multiple Access Channels', 'Designed around a common backend supporting:\n• Lightweight Mobile Interface\n• WhatsApp Voice Interaction\n• IVR / Voice Access'),

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Text('Our Goal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          'To make skill and livelihood guidance more accessible, personalized and understandable—starting with the beneficiary\'s voice.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Listen. Understand. Guide. Empower.',
                          style: TextStyle(color: AppColors.tealLight, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.6));
  }

  Widget _serviceCard(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.5)),
        ],
      ),
    );
  }
}
