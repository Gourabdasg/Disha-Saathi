import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                  const Text('Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Last Updated: September 2026', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                        Text('Privacy Commitment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.navy)),
                        SizedBox(height: 8),
                        Text(
                          'Disha Saathi respects the privacy of individuals who use our platform. This Privacy Policy explains what information may be collected, why it may be used and the choices available to users.\n\n'
                          'Disha Saathi is designed around the principle of:\n'
                          'Collect what is necessary. Use it responsibly. Protect it appropriately.',
                          style: TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _sectionCard('1. Information We May Collect', 'Depending on the features used, Disha Saathi may collect:\n\n*Personal & Profile Information*\n• Name & preferred language\n• Education level & occupation\n• Skills, experience & career interests\n• Location & training preferences\n• Livelihood constraints\n\n*Voice & Interaction Data*\n• Speech-to-text transcripts & voice notes\n• Conversational responses & chat history\n\n*Technical Information*\n• Device/browser details & IP address\n• Session info & performance logs'),
                  _sectionCard('2. How We Use Information', 'Information is used to:\n• Create a beneficiary livelihood profile\n• Perform skill-gap analysis\n• Generate training & skill recommendations\n• Identify relevant local livelihood opportunities\n• Provide voice and text AI responses\n• Maintain system usability & security'),
                  _sectionCard('3. Voice Data', 'Voice input is processed securely:\nVoice Input → Speech Processing → Text / Structured Info → Recommendation\n\nVoice recordings are processed temporarily to generate transcripts and handled responsibly.'),
                  _sectionCard('4. Consent', 'Where consent is required, Disha Saathi requests consent before collecting or processing personal information. Users are informed about data usage and storage.'),
                  _sectionCard('5. Data Minimization', 'Disha Saathi collects only the information necessary for generating personalized recommendations.'),
                  _sectionCard('6. Data Storage', 'Structured application data is stored in MongoDB / PostgreSQL with strict access control according to user roles.'),
                  _sectionCard('7. Data Security', 'Technical measures implemented include access control, authentication, authorization, encrypted API communication, and secure database configuration.'),
                  _sectionCard('8. Sharing of Information', 'Disha Saathi does NOT sell personal beneficiary information. Data is shared with integrated services solely for delivering requested features.'),
                  _sectionCard('9. Government and Institutional Use', 'Where deployed with government departments or authorized institutions, data handling complies with institutional policies and legal requirements.'),
                  _sectionCard('10. Recommendations & Automated Processing', 'Automated AI recommendations serve as decision-support guidance, not final legal or financial determinations.'),
                  _sectionCard('11. Data Retention', 'Personal information is retained only for as long as necessary for operation and legal requirements. Outdated data is securely deleted.'),
                  _sectionCard('12. User Rights', 'Users may request access, correction, or deletion of their personal information according to applicable procedures.'),
                  _sectionCard('13. Children\'s Information', 'Designed for adult skill development and livelihood guidance.'),
                  _sectionCard('14. External Links & Services', 'External links to government/training portals are governed by their respective privacy policies.'),
                  _sectionCard('15. Changes to This Privacy Policy', 'Updates to this policy will be published directly on this page.'),
                  _sectionCard('16. Contact Us', 'For privacy inquiries, contact the Disha Saathi project team through the platform.'),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.navy)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.5)),
        ],
      ),
    );
  }
}
