// common/validation/event_validator.dart
class EventValidator {
  static const List<String> _allowedKeywords = [
    // Nature et environnement
    'nature', 'environnement', 'écologie', 'écologique', 'vert', 'verte',
    'protection', 'biodiversité', 'climat', 'durable', 'sustainability',
    'reboisement', 'plantation', 'arbre', 'forêt', 'parc', 'jardin',
    'nettoyage', 'ramassage', 'déchet', 'recyclage', 'compost',
    'conservation', 'préservation', 'écosystème', 'faune', 'flore',
    'environnemental', 'écologiste', 'green', 'eco', 'sustainable',
    
    // Randonnée et activités outdoor
    'randonnée', 'rando', 'hiking', 'trek', 'trekking', 'balade',
    'promenade', 'excursion', 'sentier', 'trail', 'montagne',
    'campagne', 'plein air', 'outdoor', 'aventure', 'exploration',
    'découverte', 'naturaliste', 'observation'
  ];

  static const List<String> _allowedCategories = [
    'Randonnée',
    'Nettoyage',
    'Plantation',
    'Conservation',
    'Éducation environnementale',
    'Protection de la biodiversité',
    'Observation de la faune',
    'Restauration écologique'
  ];

  static bool isEventAllowed(String title, String description, List<String> sdgs) {
    final text = '${title.toLowerCase()} ${description.toLowerCase()}';
    
    // Vérifier les mots-clés dans le titre et la description
    final hasAllowedKeyword = _allowedKeywords.any((keyword) => text.contains(keyword));
    
    // Vérifier les SDG spécifiques (objectifs de développement durable)
    final allowedSdgs = [
      'Eco-Friendly Transportation',
      'Green Mobility', 
      'Responsible Consumption and Production',
      'Life on Land',
      'Sustainable Cities and Communities',
      'Climate Action',
      'Life Below Water',
      'Clean Water and Sanitation',
      'Affordable and Clean Energy'
    ];
    
    final hasAllowedSdg = sdgs.any((sdg) => allowedSdgs.contains(sdg));
    
    return hasAllowedKeyword || hasAllowedSdg;
  }

  static String getValidationMessage(String title, String description, List<String> sdgs) {
    if (isEventAllowed(title, description, sdgs)) {
      return '';
    }
    
    return '''
This event does not meet the platform's criteria.

Allowed events:
🌿 Nature protection and environment
🌳 Hiking and outdoor activities
♻️ Ecological and sustainable initiatives
🦋 Biodiversity conservation
🌍 Environmental education

Add keywords like: hiking, nature, environment, ecology, protection, etc.
    ''';
  }

  static List<String> getKeywordSuggestions() {
    return _allowedKeywords;
  }

  static List<String> getCategorySuggestions() {
    return _allowedCategories;
  }
}