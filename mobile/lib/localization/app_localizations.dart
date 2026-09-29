class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Sweezen Foundation',
      'tagline': 'SECTION 8 NON-PROFIT | UN SDG ALIGNED',
      'hero_heading': 'Your ₹1000 can change a life today',
      'hero_sub': 'Join thousands of donors empowering rural communities with healthcare, education, and environmental programs.',
      'btn_donate_now': 'BE THE REASON SOMEONE SMILES',
      'btn_see_impact': 'SEE OUR IMPACT',
      'nav_home': 'Home',
      'nav_projects': 'Projects',
      'nav_donate': 'Donate',
      'nav_volunteer': 'Volunteer',
      'nav_profile': 'Profile',
      'stat_projects': 'Total Projects',
      'stat_beneficiaries': 'Beneficiaries',
      'stat_volunteers': 'Volunteers',
      'stat_funds': 'Funds Raised',
      'featured_projects': 'Featured Projects',
      'upcoming_events': 'Upcoming Events',
      'latest_news': 'Latest Updates',
      'humanity_card': 'Humanity Smart ID',
      'ask_sweezen': 'Ask Sweezen AI',
      'tax_benefit': '80G Tax Exemption Available',
      'login': 'Login / Register',
      'role_volunteer': 'Volunteer',
      'role_donor': 'Donor',
      'role_beneficiary': 'Beneficiary',
      'role_researcher': 'Researcher',
      'role_staff': 'Foundation Staff',
      'role_partner': 'Partner Org',
      'offline_sync': 'Offline Field Queue',
    },
    'hi': {
      'app_title': 'स्वीजन फाउंडेशन',
      'tagline': 'धारा 8 गैर-लाभकारी | संयुक्त राष्ट्र SDG संरेखित',
      'hero_heading': 'आपका ₹1000 आज किसी का जीवन बदल सकता है',
      'hero_sub': 'स्वास्थ्य सेवा, शिक्षा और पर्यावरण कार्यक्रमों के साथ ग्रामीण समुदायों को सशक्त बनाने वाले हजारों दाताओं से जुड़ें।',
      'btn_donate_now': 'किसी की मुस्कान का कारण बनें',
      'btn_see_impact': 'हमारा प्रभाव देखें',
      'nav_home': 'होम',
      'nav_projects': 'प्रोजेक्ट्स',
      'nav_donate': 'दान करें',
      'nav_volunteer': 'स्वयंसेवक',
      'nav_profile': 'प्रोफाइल',
      'stat_projects': 'कुल प्रोजेक्ट्स',
      'stat_beneficiaries': 'लाभार्थी',
      'stat_volunteers': 'स्वयंसेवक',
      'stat_funds': 'एकत्रित राशि',
      'featured_projects': 'प्रमुख परियोजनाएं',
      'upcoming_events': 'आगामी कार्यक्रम',
      'latest_news': 'नवीनतम समाचार',
      'humanity_card': 'ह्यूमैनिटी स्मार्ट आईडी',
      'ask_sweezen': 'स्वीजन AI से पूछें',
      'tax_benefit': '80G आयकर छूट उपलब्ध',
      'login': 'लॉगिन / पंजीकरण',
      'role_volunteer': 'स्वयंसेवक',
      'role_donor': 'दाता',
      'role_beneficiary': 'लाभार्थी',
      'role_researcher': 'शोधकर्ता',
      'role_staff': 'फाउंडेशन स्टाफ',
      'role_partner': 'भागीदार संस्था',
      'offline_sync': 'ऑफलाइन फ़ील्ड सिंक',
    }
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}
