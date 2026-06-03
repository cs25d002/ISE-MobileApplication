// lib/data/plain_language_map.dart
// Hand-written plain-language descriptions for each study drug.
// Two languages: English ('en') and Telugu ('te').
// DO NOT generate these with NLP — they are manually written for accuracy.

class PlainLangEntry {
  final String whatItIsFor;
  final String howToTake;
  final String audioText;

  /// 3–4 plain-language steps describing what the drug does inside the body.
  /// Shown as a numbered step sequence below the anatomy viewer.
  /// Each step is one short sentence.
  final List<String> mechanismSteps;

  /// Pictogram codes for the illiterate-user icon row.
  /// Valid codes: 'take_with_food', 'take_without_food', 'twice_daily',
  /// 'once_daily', 'as_needed', 'apply_to_skin', 'inhale', 'do_not_stop',
  /// 'morning_and_night', 'follow_schedule', 'wash_hands'
  final List<String> pictograms;

  const PlainLangEntry({
    required this.whatItIsFor,
    required this.howToTake,
    required this.audioText,
    required this.mechanismSteps,
    required this.pictograms,
  });
}

const Map<String, Map<String, PlainLangEntry>> plainLanguageMap = {
  'metformin_01': {
    'en': PlainLangEntry(
      whatItIsFor: 'This medicine helps control the amount of sugar in your blood.',
      howToTake: 'Take one tablet twice a day. Always take it with your meals.',
      audioText: 'Metformin. This medicine helps control the amount of sugar in your blood. Take one tablet twice a day. Always take it with your meals.',
      mechanismSteps: [
        'You swallow the tablet and it enters your stomach.',
        'It travels through your blood to your liver.',
        'It tells your liver to make less sugar.',
        'Your blood sugar level goes down and stays more steady.',
      ],
      pictograms: ['take_with_food', 'twice_daily', 'morning_and_night'],
    ),
    'te': PlainLangEntry(
      whatItIsFor: 'ఈ మందు మీ రక్తంలో చక్కెర స్థాయిని నియంత్రించడంలో సహాయపడుతుంది.',
      howToTake: 'రోజుకు రెండు సార్లు భోజనంతో ఒక మాత్ర వేసుకోండి.',
      audioText: 'మెట్ఫార్మిన్. ఈ మందు మీ రక్తంలో చక్కెర స్థాయిని నియంత్రించడంలో సహాయపడుతుంది. రోజుకు రెండు సార్లు భోజనంతో ఒక మాత్ర వేసుకోండి.',
      mechanismSteps: [
        'మీరు మాత్రను మింగినప్పుడు అది కడుపులోకి వెళ్తుంది.',
        'అది రక్తం ద్వారా కాలేయానికి చేరుతుంది.',
        'ఇది కాలేయం తక్కువ చక్కెర తయారు చేయమని చెప్తుంది.',
        'మీ రక్తంలో చక్కెర స్థాయి తగ్గి స్థిరంగా ఉంటుంది.',
      ],
      pictograms: ['take_with_food', 'twice_daily', 'morning_and_night'],
    ),
    'hi': PlainLangEntry(
      whatItIsFor: 'यह दवा आपके रक्त में शर्करा की मात्रा को नियंत्रित करने में मदद करती है।',
      howToTake: 'दिन में दो बार एक गोली लें। इसे हमेशा अपने भोजन के साथ लें।',
      audioText: 'मेटफॉर्मिन। यह दवा आपके रक्त में शर्करा की मात्रा को नियंत्रित करने में मदद करती है। दिन में दो बार एक गोली लें। इसे हमेशा अपने भोजन के साथ लें।',
      mechanismSteps: [
        'आप गोली निगलते हैं और वह आपके पेट में जाती है।',
        'वह आपके खून के ज़रिए आपके जिगर (लीवर) तक पहुँचती है।',
        'यह जिगर को कम शर्करा बनाने का निर्देश देती है।',
        'आपके खून में शर्करा का स्तर कम होकर स्थिर रहता है।',
      ],
      pictograms: ['take_with_food', 'twice_daily', 'morning_and_night'],
    ),
  },

  'salbutamol_01': {
    'en': PlainLangEntry(
      whatItIsFor: 'This inhaler opens up your airways and helps you breathe more easily when you feel short of breath.',
      howToTake: 'Use 1 or 2 puffs when you need it. Shake the inhaler first. Do not use it more than 4 times in one day.',
      audioText: 'Salbutamol inhaler. This inhaler opens up your airways and helps you breathe more easily. Use 1 or 2 puffs when you need it. Shake the inhaler first. Do not use it more than 4 times in one day.',
      mechanismSteps: [
        'You press the inhaler and the medicine goes into your mouth.',
        'You breathe it deep into your lungs.',
        'It relaxes the tight muscles around your breathing tubes.',
        'Your breathing tubes open wider and air flows in more easily.',
      ],
      pictograms: ['inhale', 'as_needed', 'wash_hands'],
    ),
    'te': PlainLangEntry(
      whatItIsFor: 'ఈ ఇన్హేలర్ మీ శ్వాస నాళాలను తెరుస్తుంది మరియు శ్వాస తీసుకోవడం సులభం చేస్తుంది.',
      howToTake: 'అవసరమైనప్పుడు 1 లేదా 2 పఫ్లు వాడండి. ఒక రోజులో 4 సార్లకు మించి వాడకండి.',
      audioText: 'సాల్బుటమాల్ ఇన్హేలర్. ఈ ఇన్హేలర్ మీ శ్వాస నాళాలను తెరుస్తుంది. అవసరమైనప్పుడు 1 లేదా 2 పఫ్లు వాడండి. ఒక రోజులో 4 సార్లకు మించి వాడకండి.',
      mechanismSteps: [
        'మీరు ఇన్హేలర్ నొక్కినప్పుడు మందు మీ నోటిలోకి వెళ్తుంది.',
        'మీరు దాన్ని లోపలికి పీల్చి ఊపిరితిత్తులలోకి తీసుకుంటారు.',
        'ఇది శ్వాసనాళాల చుట్టూ ఉన్న గట్టిపడిన కండరాలను సడలిస్తుంది.',
        'శ్వాసనాళాలు వెడల్పు అవుతాయి మరియు గాలి సులభంగా వస్తుంది.',
      ],
      pictograms: ['inhale', 'as_needed', 'wash_hands'],
    ),
    'hi': PlainLangEntry(
      whatItIsFor: 'यह इनहेलर आपके वायुमार्ग को खोलता है और सांस लेने में कठिनाई होने पर आपको अधिक आसानी से सांस लेने में मदद करता है।',
      howToTake: 'ज़रूरत पड़ने पर 1 या 2 पफ का उपयोग करें। पहले इनहेलर को हिलाएं। एक दिन में 4 से अधिक बार इसका उपयोग न करें।',
      audioText: 'सालबुटामोल इनहेलर। यह इनहेलर आपके वायुमार्ग को खोलता है। ज़रूरत पड़ने पर 1 या 2 पफ का उपयोग करें। एक दिन में 4 से अधिक बार उपयोग न करें।',
      mechanismSteps: [
        'आप इनहेलर दबाते हैं और दवा आपके मुँह में जाती है।',
        'आप इसे गहरी सांस के साथ अपने फेफड़ों में लेते हैं।',
        'यह सांस की नलियों के आसपास की तंग मांसपेशियों को आराम देती है।',
        'आपकी सांस की नलियाँ खुल जाती हैं और हवा आसानी से अंदर आती है।',
      ],
      pictograms: ['inhale', 'as_needed', 'wash_hands'],
    ),
  },

  'betamethasone_01': {
    'en': PlainLangEntry(
      whatItIsFor: 'This cream reduces redness, itching, and swelling on your skin.',
      howToTake: 'Apply a thin layer to the affected area of skin twice a day. Wash your hands before and after applying.',
      audioText: 'Betamethasone cream. This cream reduces redness, itching, and swelling on your skin. Apply a thin layer to the affected area twice a day. Wash your hands before and after applying.',
      mechanismSteps: [
        'You apply a thin layer of cream to the red or itchy skin.',
        'The cream soaks into the top layers of your skin.',
        'It reduces the chemicals in your skin that cause swelling and itching.',
        'The redness and itch calm down over the next few hours.',
      ],
      pictograms: ['apply_to_skin', 'twice_daily', 'wash_hands'],
    ),
    'te': PlainLangEntry(
      whatItIsFor: 'ఈ క్రీమ్ చర్మంపై ఎరుపు, దురద మరియు వాపును తగ్గిస్తుంది.',
      howToTake: 'ప్రభావిత చర్మంపై రోజుకు రెండు సార్లు సన్నగా పూయండి. వేయడానికి ముందు మరియు తర్వాత చేతులు కడుక్కోండి.',
      audioText: 'బెటామెతసోన్ క్రీమ్. ఈ క్రీమ్ చర్మంపై ఎరుపు, దురద మరియు వాపును తగ్గిస్తుంది. ప్రభావిత చర్మంపై రోజుకు రెండు సార్లు సన్నగా పూయండి.',
      mechanismSteps: [
        'మీరు ఎరుపు లేదా దురద ఉన్న చర్మంపై సన్నని పొరలా క్రీమ్ పూస్తారు.',
        'క్రీమ్ మీ చర్మం పై పొరలలోకి ఇంకుతుంది.',
        'ఇది చర్మంలో వాపు మరియు దురదకు కారణమయ్యే రసాయనాలను తగ్గిస్తుంది.',
        'కొన్ని గంటల్లో ఎరుపు మరియు దురద తగ్గుతాయి.',
      ],
      pictograms: ['apply_to_skin', 'twice_daily', 'wash_hands'],
    ),
    'hi': PlainLangEntry(
      whatItIsFor: 'यह क्रीम आपकी त्वचा पर लालिमा, खुजली और सूजन को कम करती है।',
      howToTake: 'दिन में दो बार त्वचा के प्रभावित हिस्से पर एक पतली परत लगाएं। लगाने से पहले और बाद में अपने हाथ धो लें।',
      audioText: 'बीटामेथासोन क्रीम। यह क्रीम आपकी त्वचा पर लालिमा, खुजली और सूजन को कम करती. दिन में दो बार त्वचा के प्रभावित हिस्से पर एक पतली परत लगाएं।',
      mechanismSteps: [
        'आप लाल या खुजली वाली त्वचा पर एक पतली परत क्रीम लगाते हैं।',
        'क्रीम आपकी त्वचा की ऊपरी परतों में समा जाती है।',
        'यह त्वचा में उन रसायनों को कम करती है जो सूजन और खुजली का कारण बनते हैं।',
        'कुछ घंटों में लालिमा और खुजली शांत हो जाती है।',
      ],
      pictograms: ['apply_to_skin', 'twice_daily', 'wash_hands'],
    ),
  },

  'amlodipine_01': {
    'en': PlainLangEntry(
      whatItIsFor: 'This medicine helps lower your blood pressure and keeps your heart working smoothly.',
      howToTake: 'Take one tablet once a day. You can take it at any time of day but try to take it at the same time each day.',
      audioText: 'Amlodipine. This medicine helps lower your blood pressure. Take one tablet once a day, at the same time each day.',
      mechanismSteps: [
        'You swallow the tablet and it enters your bloodstream.',
        'It travels to the walls of your blood vessels.',
        'It relaxes and widens the blood vessel walls.',
        'Your blood flows more easily and your blood pressure goes down.',
      ],
      pictograms: ['once_daily', 'take_without_food', 'morning_and_night'],
    ),
    'te': PlainLangEntry(
      whatItIsFor: 'ఈ మందు మీ రక్తపోటును తగ్గించడంలో సహాయపడుతుంది మరియు మీ గుండె సరిగ్గా పనిచేయడానికి సహాయం చేస్తుంది.',
      howToTake: 'రోజుకు ఒకసారి ఒక మాత్ర వేసుకోండి. ప్రతి రోజూ అదే సమయంలో వేసుకోవడానికి ప్రయత్నించండి.',
      audioText: 'అమ్లోడిపిన్. ఈ మందు మీ రక్తపోటును తగ్గిస్తుంది. రోజుకు ఒకసారి, అదే సమయంలో ఒక మాత్ర వేసుకోండి.',
      mechanismSteps: [
        'మీరు మాత్రను మింగినప్పుడు అది రక్తప్రవాహంలోకి వెళ్తుంది.',
        'ఇది మీ రక్తనాళాల గోడలకు చేరుతుంది.',
        'ఇది రక్తనాళాల గోడలను సడలించి వెడల్పు చేస్తుంది.',
        'మీ రక్తం సుభంగా ప్రవహిస్తుంది మరియు రక్తపోటు తగ్గుతుంది.',
      ],
      pictograms: ['once_daily', 'take_without_food', 'morning_and_night'],
    ),
    'hi': PlainLangEntry(
      whatItIsFor: 'यह दवा आपके रक्तचाप को कम करने में मदद करती है और आपके दिल को सुचारू रूप से काम करने में मदद करती है।',
      howToTake: 'दिन में एक बार एक गोली लें। इसे हर दिन एक ही समय पर लेने का प्रयास करें।',
      audioText: 'एम्लोडिपिन। यह दवा आपके रक्तचाप को कम करती है। दिन में एक बार, हर दिन एक ही समय पर एक गोली लें।',
      mechanismSteps: [
        'आप गोली निगलते हैं और वह आपके खून में मिल जाती है।',
        'यह आपकी रक्त वाहिकाओं की दीवारों तक पहुँचती है।',
        'यह रक्त वाहिकाओं की दीवारों को ढीला और चौड़ा करती है।',
        'आपका खून आसानी से बहता है और रक्तचाप कम हो जाता है।',
      ],
      pictograms: ['once_daily', 'take_without_food', 'morning_and_night'],
    ),
  },

  'prednisolone_01': {
    'en': PlainLangEntry(
      whatItIsFor: 'This medicine calms down your immune system and reduces swelling and inflammation inside your body.',
      howToTake: 'Take the tablets as shown in your tapering schedule. Start with 4 tablets a day and reduce as instructed. Always take with food. Do not stop suddenly.',
      audioText: 'Prednisolone. This medicine calms down your immune system and reduces inflammation. Follow your tapering schedule carefully. Start with 4 tablets a day and reduce as instructed. Always take with food. Do not stop suddenly.',
      mechanismSteps: [
        'You swallow the tablet and it enters your bloodstream.',
        'It travels throughout your whole body — not just one part.',
        'It reduces the activity of your immune system, which is overreacting and causing swelling.',
        'Swelling and pain go down — but do not stop taking it suddenly, your body needs to adjust slowly.',
      ],
      pictograms: ['take_with_food', 'follow_schedule', 'do_not_stop'],
    ),
    'te': PlainLangEntry(
      whatItIsFor: 'ఈ మందు మీ రోగనిరోధక వ్యవస్థను శాంతింపజేస్తుంది మరియు శరీరంలో వాపు మరియు మంటను తగ్గిస్తుంది.',
      howToTake: 'మీ టేపరింగ్ షెడ్యూల్ ప్రకారం మాత్రలు వేసుకోండి. రోజుకు 4 మాత్రలతో మొదలుపెట్టండి. ఆహారంతో వేసుకోండి. ఆకస్మికంగా ఆపవద్దు.',
      audioText: 'ప్రెడ్నిసోలోన్. ఈ మందు మీ రోగనిరోధక వ్యవస్థను శాంతింపజేస్తుంది. మీ షెడ్యూల్ ప్రకారం జాగ్రత్తగా వేసుకోండి. రోజుకు 4 మాత్రలతో మొదలుపెట్టండి. ఆహారంతో తీసుకోండి.',
      mechanismSteps: [
        'మీరు మాత్రను మింగినప్పుడు అది రక్తప్రవాహంలోకి వెళ్తుంది.',
        'ఇది మొత్తం శరీరంలో ప్రయాణిస్తుంది — ఒక్క భాగంలో మాత్రమే కాదు.',
        'ఇది రోగనిరోధక వ్యవస్థ యొక్క అతిగా స్పందించడాన్ని తగ్గిస్తుంది, ఇది వాపు కలిగిస్తుంది.',
        'వాపు మరియు నొప్పి తగ్గుతాయి — కానీ ఆకస్మికంగా ఆపవద్దు, శరీరానికి నెమ్మదిగా తగ్గించడం అవసరం.',
      ],
      pictograms: ['take_with_food', 'follow_schedule', 'do_not_stop'],
    ),
    'hi': PlainLangEntry(
      whatItIsFor: 'यह दवा आपके प्रतिरक्षा प्रणाली को शांत करती है और आपके शरीर के अंदर सूजन को कम करती है।',
      howToTake: 'अपने टेपरिंग शेड्यूल में दिखाए अनुसार गोलियां लें। दिन में 4 गोलियों से शुरू करें। हमेशा भोजन के साथ लें। अचानक बंद न करें।',
      audioText: 'प्रेडनिसोलोन। यह दवा आपकी प्रतिरक्षा प्रणाली को शांत करती है। शेड्यूल का पालन करें। दिन में 4 गोलियों से शुरू करें। भोजन के साथ लें। अचानक बंद न करें।',
      mechanismSteps: [
        'आप गोली निगलते हैं और वह आपके खून में मिल जाती है।',
        'यह पूरे शरीर में फैलती है — केवल एक हिस्से में नहीं।',
        'यह आपकी प्रतिरक्षा प्रणाली की अतिसक्रियता को कम करती है जो सूजन पैदा कर रही है।',
        'सूजन और दर्द कम होते हैं — लेकिन इसे अचानक बंद न करें, शरीर को धीरे-धीरे कम करना जरूरी है।',
      ],
      pictograms: ['take_with_food', 'follow_schedule', 'do_not_stop'],
    ),
  },
};
