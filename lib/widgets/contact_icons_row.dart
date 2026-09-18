import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

/// WhatsApp + IVR call icon buttons — an alternate, lower-bandwidth channel
/// into the same AI Livelihood Assistant, matching the "App + WhatsApp + IVR"
/// access model from the original SIH proposal (see feasibility slide).
///
/// Icon-only by design, no text labels: this is a standard pattern in
/// government/utility apps and doesn't need extra explanation in the UI.
///
/// IMPORTANT: for these buttons to work on Android 11+ (API 30+), your
/// AndroidManifest.xml MUST include a <queries> block declaring the
/// "https" and "tel" VIEW intents (see project docs / earlier chat).
/// Without that, canLaunchUrl() silently returns false even when
/// WhatsApp / the dialer are available.
class ContactIconsRow extends StatelessWidget {
  // Full international format, no "+" and no leading zero: 91 + 10-digit number.
  static const String whatsappNumber = '916200590790';
  static const String ivrNumber = '1800XXXXXXX'; // TODO: replace with your real IVR helpline

  const ContactIconsRow({super.key});

  static const String _whatsappSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>
<path d="M12.014 2.003c-5.514 0-9.987 4.474-9.987 9.987 0 1.762.464 3.483 1.346 4.997L2 22l5.135-1.348a9.955 9.955 0 004.879 1.24h.004c5.514 0 9.987-4.474 9.987-9.987 0-2.669-1.038-5.176-2.925-7.063a9.935 9.935 0 00-7.066-2.839zm0 18.29a8.283 8.283 0 01-4.223-1.156l-.303-.18-3.048.8.813-2.969-.198-.305a8.284 8.284 0 01-1.267-4.396c0-4.583 3.729-8.312 8.313-8.312 2.221 0 4.309.865 5.878 2.437a8.263 8.263 0 012.436 5.876c0 4.583-3.729 8.312-8.312 8.312z"/>
</svg>
''';

  /// Opens a WhatsApp chat directly with [whatsappNumber].
  ///
  /// Tries the native `whatsapp://send` scheme first (opens the app
  /// instantly, no browser hop). Falls back to the `https://wa.me/`
  /// click-to-chat link if the native scheme isn't launchable — this
  /// still opens WhatsApp itself when installed (wa.me redirects into
  /// the app), and only drops to a browser if WhatsApp truly isn't
  /// installed on the device.
  Future<void> _openWhatsApp(BuildContext context) async {
    final nativeUri = Uri.parse(
      'whatsapp://send?phone=$whatsappNumber&text=${Uri.encodeComponent("Hi, I need help with Disha Saathi")}',
    );
    final webUri = Uri.parse('https://wa.me/$whatsappNumber');

    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }
      if (context.mounted) {
        _showError(context, 'WhatsApp is not installed on this device');
      }
    } catch (e) {
      debugPrint('WhatsApp launch error: $e');
      if (context.mounted) {
        _showError(context, 'Could not open WhatsApp');
      }
    }
  }

  /// Opens the phone dialer pre-filled with [ivrNumber].
  /// Requires a `tel` VIEW <queries> entry in AndroidManifest.xml on API 30+.
  Future<void> _callIvr(BuildContext context) async {
    final uri = Uri.parse('tel:$ivrNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (context.mounted) {
        _showError(context, 'Could not open dialer');
      }
    } catch (e) {
      debugPrint('Dialer launch error: $e');
      if (context.mounted) {
        _showError(context, 'Could not open dialer');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _iconButton(
          background: const Color(0xFF25D366), // WhatsApp brand green
          tooltip: 'Chat on WhatsApp',
          onTap: () => _openWhatsApp(context),
          child: SvgPicture.string(
            _whatsappSvg,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 24),
        _iconButton(
          background: AppColors.navy,
          tooltip: 'Call IVR helpline',
          onTap: () => _callIvr(context),
          child: const Icon(Icons.call_rounded, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _iconButton({
    required Widget child,
    required Color background,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: background.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: child,
        ),
      ),
    );
  }
}