// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaqItemModel _$FaqItemModelFromJson(Map<String, dynamic> json) => FaqItemModel(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'Umumiy',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
    );

Map<String, dynamic> _$FaqItemModelToJson(FaqItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'question': instance.question,
      'answer': instance.answer,
    };

SupportTicketModel _$SupportTicketModelFromJson(Map<String, dynamic> json) =>
    SupportTicketModel(
      id: json['id'] as String,
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String? ?? '',
      orderId: json['order_id'] as String?,
      status: json['status'] as String? ?? 'open',
      createdAt: json['created_at'] as String? ?? '',
    );

Map<String, dynamic> _$SupportTicketModelToJson(SupportTicketModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'message': instance.message,
      'order_id': instance.orderId,
      'status': instance.status,
      'created_at': instance.createdAt,
    };
