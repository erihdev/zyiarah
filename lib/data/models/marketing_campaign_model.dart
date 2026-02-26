class MarketingCampaignModel {
  final String id;
  final String title;
  final String? body;
  final String? imageUrl;
  final String type; // push, popup
  final String? targetScreen;
  final String status;
  final DateTime? createdAt;

  MarketingCampaignModel({
    required this.id,
    required this.title,
    this.body,
    this.imageUrl,
    required this.type,
    this.targetScreen,
    this.status = 'active',
    this.createdAt,
  });

  factory MarketingCampaignModel.fromMap(Map<String, dynamic> map) {
    return MarketingCampaignModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      imageUrl: map['image_url'],
      type: map['type'],
      targetScreen: map['target_screen'],
      status: map['status'] ?? 'active',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'type': type,
      'target_screen': targetScreen,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
