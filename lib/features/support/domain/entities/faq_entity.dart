/// Domain entity representing a Help Center FAQ item.
class FaqEntity {
  const FaqEntity({
    required this.id,
    required this.questionUz,
    required this.questionRu,
    required this.questionEn,
    required this.answerUz,
    required this.answerRu,
    required this.answerEn,
    required this.category,
  });

  final String id;
  final String questionUz;
  final String questionRu;
  final String questionEn;
  final String answerUz;
  final String answerRu;
  final String answerEn;
  final String category;

  String localizedQuestion(String lang) {
    switch (lang) {
      case 'ru':
        return questionRu;
      case 'en':
        return questionEn;
      case 'uz':
      default:
        return questionUz;
    }
  }

  String localizedAnswer(String lang) {
    switch (lang) {
      case 'ru':
        return answerRu;
      case 'en':
        return answerEn;
      case 'uz':
      default:
        return answerUz;
    }
  }
}
