import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class PmAjayGiaDetailsScreen extends StatelessWidget {
  const PmAjayGiaDetailsScreen({super.key});

  Future<void> _launchPortal() async {
    final uri = Uri.parse('https://pm-ajay.dosje.gov.in');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

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
                  const Text('PM-AJAY · GIA Scheme Details', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Grant-in-Aid for Scheduled Caste (SC) Beneficiaries', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _infoCard(
                    title: 'About PM-AJAY Scheme',
                    icon: Icons.account_balance_rounded,
                    iconColor: AppColors.navy,
                    body: 'Pradhan Mantri Anusuchit Jaati Abhyuday Yojana (PM-AJAY) is a merged central scheme under the Ministry of Social Justice and Empowerment aimed at reducing poverty among Scheduled Caste (SC) communities through skill development, livelihood generation, and infrastructure development.',
                  ),
                  const SizedBox(height: 16),

                  _infoCard(
                    title: 'Grant-in-Aid (GIA) Assistance',
                    icon: Icons.monetization_on_rounded,
                    iconColor: AppColors.success,
                    body: 'Under the GIA component, eligible SC beneficiaries receive financial grants up to ₹50,000 per beneficiary or ₹10 Lakhs per Self-Help Group (SHG) for skill development, machinery acquisition, and micro-enterprise setup.',
                  ),
                  const SizedBox(height: 16),

                  _sectionHeader('Key Scheme Benefits'),
                  const SizedBox(height: 10),
                  _benefitTile(Icons.school_rounded, '100% Free NSQF Skill Training', 'Government-funded skilling in NSDC, PMKK, and State skill centers.'),
                  _benefitTile(Icons.work_rounded, 'Livelihood & Tool-Kit Subsidy', 'Financial grant support for purchasing equipment and tools.'),
                  _benefitTile(Icons.verified_user_rounded, 'Official NSQF Certification', 'Recognized skill qualification certificates for job placements.'),
                  _benefitTile(Icons.groups_rounded, 'SHG & Enterprise Support', 'Assistance for setting up individual or group micro-enterprises.'),

                  const SizedBox(height: 20),
                  _sectionHeader('Eligibility Criteria'),
                  const SizedBox(height: 10),
                  _checkTile('Must belong to Scheduled Caste (SC) community.'),
                  _checkTile('Family annual income compliant with government guidelines.'),
                  _checkTile('Possess valid SC Caste Certificate & Aadhaar verification.'),
                  _checkTile('Age between 18 to 45 years for skill training.'),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.headset_mic_rounded, color: AppColors.teal),
                            SizedBox(width: 10),
                            Text('National Helpline & Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text('Ministry of Social Justice & Empowerment\nGovernment of India', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted, height: 1.4)),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(Icons.phone_in_talk_rounded, color: AppColors.navy, size: 18),
                            SizedBox(width: 8),
                            Text('Toll-Free Helpline: 1800-11-0001', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navy)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.teal),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _launchPortal,
                            icon: const Icon(Icons.language_rounded, color: AppColors.teal, size: 18),
                            label: const Text('Visit PM-AJAY Official Portal', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required String title, required IconData icon, required Color iconColor, required String body}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy)),
            ],
          ),
          const SizedBox(height: 12),
          Text(body, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.6));
  }

  Widget _benefitTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.teal, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.navy)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkTile(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }
}
