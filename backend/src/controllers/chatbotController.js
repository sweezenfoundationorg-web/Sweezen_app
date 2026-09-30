exports.askSweezen = async (req, res) => {
  try {
    const { question, language } = req.body;
    const q = (question || '').toLowerCase();
    const isHindi = language === 'hi' || q.includes('नमस्ते') || q.includes('दान') || q.includes('क्या');

    let responseText = '';
    let sources = [];
    let requiresEscalation = false;

    if (q.includes('tax') || q.includes('80g') || q.includes('exemption') || q.includes('टैक्स')) {
      responseText = isHindi 
        ? 'स्वीजन फाउंडेशन की सभी दान राशियां आयकर अधिनियम की धारा 80G के तहत 50% कर छूट के लिए पात्र हैं। दान पूर्ण होते ही तुरंत डिजिटल 80G ई-रसीद प्राप्त करें।'
        : 'All donations to Sweezen Foundation are eligible for 50% tax exemption under Section 80G of the Income Tax Act (Reg No: AAATS9012E20261). You will receive an instant downloadable 80G e-receipt immediately after donating.';
      sources = ['Income Tax Act Section 80G Approval Certificate #80G/2026/SWZ', 'Sweezen Annual Audit Report Q3 2026'];
    } else if (q.includes('donate') || q.includes('payment') || q.includes('upi') || q.includes('दान')) {
      responseText = isHindi
        ? 'आप ऐप के "Donate" टैब से UPI, डेबिट/क्रेडिट कार्ड या नेट बैंकिंग के जरिए किसी भी प्रोजेक्ट या सामान्य फंड में आसानी से दान कर सकते हैं।'
        : 'You can easily donate using UPI, Debit/Credit Card, or Net Banking via Razorpay by visiting the "Donate" tab or clicking "BE THE REASON SOMEONE SMILES" on any project page.';
      sources = ['Sweezen Verified Payment Portal Documentation'];
    } else if (q.includes('volunteer') || q.includes('join') || q.includes('task') || q.includes('स्वयंसेवक')) {
      responseText = isHindi
        ? 'स्वयंसेवक बनने के लिए प्रोफाइल रजिस्टर करें, अपने कौशल जोड़ें और "Volunteer" डैशबोर्ड पर असाइन किए गए फ़ील्ड कार्यों को पूरा करके इम्पैक्ट पॉइंट्स कमाएं।'
        : 'To become a volunteer, complete registration, add your skills, and view your assigned field tasks in the "Volunteer" tab to start earning impact points and badges!';
      sources = ['Sweezen Volunteer Framework 2026 Guidelines'];
    } else if (q.includes('humanity') || q.includes('card') || q.includes('smart id') || q.includes('कार्ड')) {
      responseText = isHindi
        ? 'ह्यूमैनिटी कार्ड ग्रामीण लाभार्थियों के लिए एक डिजिटल स्मार्ट आईडी है। फ़ील्ड स्वयंसेवक क्यूआर कोड स्कैन करके स्वास्थ्य और शिक्षा सेवाओं को क्लाउड पर तुरंत रिकॉर्ड करते हैं।'
        : 'The Humanity Card is a digital Smart ID for beneficiaries. Field volunteers scan the QR code at service points to instantly record health and education on the secure cloud database.';
      sources = ['Sweezen Rural Digital ID Guidelines'];
    } else if (q.includes('human') || q.includes('agent') || q.includes('talk') || q.includes('help') || q.includes('शिकायत') || q.includes('बात')) {
      responseText = isHindi
        ? 'मैं आपकी समस्या को Sweezen फाउंडेशन सहायता टीम को हस्तांतरित कर रहा हूँ। हमारी टीम आपसे WhatsApp या फोन पर तुरंत संपर्क करेगी।'
        : 'I am escalating your query to a Sweezen Foundation Support Representative. Our team will contact you via phone or WhatsApp shortly.';
      requiresEscalation = true;
      sources = ['Sweezen Support Escalation Desk'];
    } else {
      responseText = isHindi
        ? 'नमस्ते! मैं स्वीजन AI सहायक हूँ। मैं आपकी दान, स्वयंसेवा, 80G टैक्स रसीद, ह्यूमैनिटी कार्ड या हमारे प्रोजेक्ट्स के बारे में सहायता कर सकता हूँ।'
        : 'Hello! I am Sweezen AI Assistant. I can help you with donations, 80G tax benefit receipts, volunteer task reporting, Humanity Smart IDs, and active Foundation programs. How may I assist you today?';
      sources = ['Sweezen Foundation Official Knowledge Base'];
    }

    return res.status(200).json({
      success: true,
      answer: responseText,
      sources,
      requires_escalation: requiresEscalation,
      escalation_contact: requiresEscalation ? '+91 98765 43210 (Support Desk)' : null,
      quick_suggestions: [
        'How do I claim 80G tax benefit?',
        'Talk to Human Support Representative',
        'Show active healthcare projects',
        'How to scan Humanity Smart ID?'
      ]
    });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Chatbot service error' });
  }
};

