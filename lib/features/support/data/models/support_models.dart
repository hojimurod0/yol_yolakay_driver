import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/support_entities.dart';

part 'support_models.g.dart';

@JsonSerializable()
class FaqItemModel {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'category', defaultValue: 'Umumiy')
  final String category;
  @JsonKey(name: 'question', defaultValue: '')
  final String question;
  @JsonKey(name: 'answer', defaultValue: '')
  final String answer;

  const FaqItemModel({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
  });

  factory FaqItemModel.fromJson(Map<String, dynamic> json) =>
      _$FaqItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$FaqItemModelToJson(this);

  FaqItemEntity toEntity() {
    return FaqItemEntity(
      id: id,
      category: category,
      question: question,
      answer: answer,
    );
  }
}

@JsonSerializable()
class SupportTicketModel {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'subject', defaultValue: '')
  final String subject;
  @JsonKey(name: 'message', defaultValue: '')
  final String message;
  @JsonKey(name: 'order_id')
  final String? orderId;
  @JsonKey(name: 'status', defaultValue: 'open')
  final String status;
  @JsonKey(name: 'created_at', defaultValue: '')
  final String createdAt;

  const SupportTicketModel({
    required this.id,
    required this.subject,
    required this.message,
    this.orderId,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupportTicketModelToJson(this);

  SupportTicketEntity toEntity() {
    return SupportTicketEntity(
      id: id,
      subject: subject,
      message: message,
      orderId: orderId,
      status: status,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
