import 'package:flutter/material.dart';

class AudioScript {
  final String siteId;
  final String siteName;
  final String langCode; // 'en', 'si', 'ta'
  final String title;
  final String bodyText;
  final Duration approxDuration;

  const AudioScript({
    required this.siteId,
    required this.siteName,
    required this.langCode,
    required this.title,
    required this.bodyText,
    required this.approxDuration,
  });
}

/// Fallback built-in audio guide scripts for key Sri Lankan heritage sites.
class AudioGuideService {
  static final Map<String, List<AudioScript>> _scripts = {
    'sigiriya': [
      const AudioScript(
        siteId: 'sigiriya',
        siteName: 'Sigiriya Rock Fortress',
        langCode: 'en',
        title: 'The Fortress in the Clouds',
        bodyText:
            'Welcome to Sigiriya, the 5th-century masterpiece of King Kashyapa. Rising nearly 200 meters above the jungle, this ancient palace complex features the world-famous Frescoes of the Cloud Maidens, a polished Mirror Wall adorned with ancient graffiti, and the monumental Lion Gate pathway leading to the sky Palace summit.',
        approxDuration: Duration(seconds: 45),
      ),
      const AudioScript(
        siteId: 'sigiriya',
        siteName: 'Sigiriya Rock Fortress',
        langCode: 'si',
        title: 'සීගිරිය ඓතිහාසික විස්තරය',
        bodyText:
            'සීගිරිය යනු පස්වන සියවසේ කාශ්‍යප රජතුමා විසින් නිර්මාණය කරන ලද ලෝක උරුම අරුමයකි. මීටර් දෙසීයක් පමණ උසින් පිහිටි මෙම පර්වතය මත සිංහ ද්වාරය, කැටපත් පවුර සහ ජගත් ප්‍රකට සීගිරි ළඳුන්ගේ බිතුසිතුවම් පිහිටා ඇත.',
        approxDuration: Duration(seconds: 40),
      ),
      const AudioScript(
        siteId: 'sigiriya',
        siteName: 'Sigiriya Rock Fortress',
        langCode: 'ta',
        title: 'சிகிரியா வரலாறு',
        bodyText:
            'சிகிரியா என்பது ஐந்தாம் நூற்றாண்டில் காசியப்ப மன்னரால் கட்டப்பட்ட உலகப் புகழ்பெற்ற கோட்டையாகும். சிங்க வாயில், கண்ணாடிச் சுவர் மற்றும் புகழ்பெற்ற ஓவியங்கள் இதன் சிறப்பம்சங்களாகும்.',
        approxDuration: Duration(seconds: 35),
      ),
    ],
    'galle_fort': [
      const AudioScript(
        siteId: 'galle_fort',
        siteName: 'Galle Dutch Fort',
        langCode: 'en',
        title: 'Ramparts of the Indian Ocean',
        bodyText:
            'Founded by the Portuguese in 1588 and fortified by the Dutch in the 17th century, Galle Fort stands as Europe’s finest living fortified city in Asia. Walk along the historic bastions, view the iconic white Lighthouse, and experience four centuries of colonial architecture.',
        approxDuration: Duration(seconds: 40),
      ),
      const AudioScript(
        siteId: 'galle_fort',
        siteName: 'Galle Dutch Fort',
        langCode: 'si',
        title: 'ගාල්ල ලන්දේසි බලකොටුව',
        bodyText:
            '1588 දී පෘතුගීසීන් විසින් ආරම්භ කර පසුව 17 වන සියවසේදී ලන්දේසීන් විසින් ශක්තිමත් කරන ලද ගාලු බලකොටුව ආසියාවේ පිහිටි හොඳම සංරක්ෂිත යුරෝපීය බලකොටුවකි.',
        approxDuration: Duration(seconds: 35),
      ),
    ],
    'temple_tooth': [
      const AudioScript(
        siteId: 'temple_tooth',
        siteName: 'Temple of the Sacred Tooth Relic',
        langCode: 'en',
        title: 'Sanctuary of Sri Dalada Maligawa',
        bodyText:
            'Nestled in the hill capital of Kandy, Sri Dalada Maligawa holds the sacred tooth relic of the Buddha. For centuries, this royal palace complex has served as the spiritual heart of Sri Lanka and a bastion of Sinhala Buddhist culture.',
        approxDuration: Duration(seconds: 40),
      ),
    ],
  };

  static List<AudioScript> getScriptsForSite(String siteId) {
    final key = siteId.toLowerCase().replaceAll(' ', '_');
    if (_scripts.containsKey(key)) {
      return _scripts[key]!;
    }
    // Generic script generator if specific site is missing
    final cleanName = siteId.replaceAll('_', ' ');
    return [
      AudioScript(
        siteId: siteId,
        siteName: cleanName,
        langCode: 'en',
        title: 'Heritage Profile: $cleanName',
        bodyText:
            'You are exploring $cleanName, a designated sanctuary of Sri Lankan heritage. This landmark reflects centuries of craftsmanship, cultural identity, and architectural legacy.',
        approxDuration: const Duration(seconds: 25),
      ),
    ];
  }
}
