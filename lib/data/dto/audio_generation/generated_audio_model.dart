import 'package:login_flutter/domain/entities/generated_audio_entity.dart';

class GeneratedAudioModel extends GeneratedAudioEntity {
  const GeneratedAudioModel({
    required super.id,
    required super.title,
    required super.prompt,
    required super.audioUrl,
    required super.imageUrl,
    required super.durationSeconds,
    required super.provider,
  });

  factory GeneratedAudioModel.fromJson(Map<String, dynamic> json) {
    return GeneratedAudioModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
      audioUrl:
          json['audioUrl']?.toString() ?? json['audio_url']?.toString() ?? '',
      imageUrl:
          json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '',
      durationSeconds:
          (json['durationSeconds'] as num?)?.toInt() ??
          (json['duration_seconds'] as num?)?.toInt() ??
          0,
      provider: json['provider']?.toString() ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prompt': prompt,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'durationSeconds': durationSeconds,
      'provider': provider,
    };
  }
}
