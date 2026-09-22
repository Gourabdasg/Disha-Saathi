import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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
                  const Text('Terms and Conditions', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
                    child: const Text(
                      'Welcome to Disha Saathi. These Terms and Conditions govern your use of the Disha Saathi platform, website, prototype and related services.\n\n'
                      'By accessing or using Disha Saathi, you acknowledge that you have read and understood these Terms and agree to use the platform responsibly.',
                      style: TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _sectionCard('1. About Disha Saathi', 'Disha Saathi is an AI-powered livelihood guidance platform designed to help users explore potentially relevant skill-development, training and livelihood pathways.\n\nThe platform may use information provided by the user together with structured skill, qualification, training and opportunity data to generate guidance.'),
                  _sectionCard('2. Eligibility', 'You should provide accurate information when interacting with Disha Saathi.\n\nIf you are using the platform on behalf of another person or organization, you should have the appropriate authority to provide the information and use the service for that purpose.'),
                  _sectionCard('3. Information Provided by Users', 'The quality of recommendations depends partly on the information provided.\n\nUsers should provide accurate and relevant information about:\n• Education\n• Skills\n• Experience\n• Interests\n• Location\n• Occupation\n• Preferences\n• Other requested information\n\nIncomplete or inaccurate information may result in less relevant guidance.'),
                  _sectionCard('4. AI-Generated Guidance', 'Disha Saathi uses AI and automated recommendation logic to assist users.\n\nAI-generated recommendations are intended as guidance and informational support and should not automatically be treated as a final decision regarding:\n• Government scheme eligibility\n• Admission to a training programme\n• Employment selection\n• Financial assistance or loan approval\n• Guaranteed employment or income'),
                  _sectionCard('5. Training and Opportunity Information', 'Training courses, qualifications, job roles and opportunities may change over time.\n\nDisha Saathi may depend on external, verified, curated or institution-provided data. Therefore, the availability, eligibility, location, schedule or status of an opportunity may change. Users should verify important details before taking a final decision.'),
                  _sectionCard('6. No Guarantee of Employment or Income', 'Disha Saathi provides guidance and recommendations.\n\nUse of the platform does not guarantee:\n• Employment or job placement\n• Admission to training programmes\n• Selection by employers\n• Government benefit approval\n\nActual outcomes depend on market conditions, eligibility, and external factors.'),
                  _sectionCard('7. Responsible Use', 'Users must not:\n• Provide deliberately false information\n• Attempt to misuse the platform or interfere with security\n• Upload malicious content or engage in unlawful activities\n• Attempt unauthorized access to another user\'s information'),
                  _sectionCard('8. Third-Party Services', 'Disha Saathi may integrate third-party services such as speech processing, communication platforms, mapping services, and government data sources. Usage is subject to their respective terms.'),
                  _sectionCard('9. Service Availability', 'As an evolving digital platform, features may be updated, modified, or temporarily unavailable during maintenance.'),
                  _sectionCard('10. Accuracy and Reliability', 'Automated systems may occasionally produce incomplete or outdated information. Users should verify critical details with official sources.'),
                  _sectionCard('11. Intellectual Property', 'The Disha Saathi name, software, interface design, and content are protected by applicable intellectual-property rights.'),
                  _sectionCard('12. Privacy', 'Information collected is handled in accordance with our Privacy Policy to provide and improve the service.'),
                  _sectionCard('13. Changes to These Terms', 'These Terms may be updated as the platform evolves. The latest version will always be published on the platform.'),
                  _sectionCard('14. Contact', 'For questions regarding these Terms and Conditions, please contact the Disha Saathi project team through the platform.'),

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
