class ContractModel {
  final String id;
  final String userId;
  final String bookingId;
  final String? workerId;
  final DateTime startDate;
  final DateTime endDate;
  final String? signatureUrl;
  final String? pdfUrl;
  final String status;
  final String renewalStatus;
  final DateTime? createdAt;

  ContractModel({
    required this.id,
    required this.userId,
    required this.bookingId,
    this.workerId,
    required this.startDate,
    required this.endDate,
    this.signatureUrl,
    this.pdfUrl,
    this.status = 'active',
    this.renewalStatus = 'none',
    this.createdAt,
  });

  factory ContractModel.fromMap(Map<String, dynamic> map) {
    return ContractModel(
      id: map['id'],
      userId: map['user_id'],
      bookingId: map['booking_id'],
      workerId: map['worker_id'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      signatureUrl: map['signature_url'],
      pdfUrl: map['pdf_url'],
      status: map['status'] ?? 'active',
      renewalStatus: map['renewal_status'] ?? 'none',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'booking_id': bookingId,
      'worker_id': workerId,
      'start_date': startDate.toIso8601String().split('T')[0], // Only Date
      'end_date': endDate.toIso8601String().split('T')[0],
      'signature_url': signatureUrl,
      'pdf_url': pdfUrl,
      'status': status,
      'renewal_status': renewalStatus,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
