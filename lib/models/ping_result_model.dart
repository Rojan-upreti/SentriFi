class PingResultModel {
  const PingResultModel({
    required this.sequence,
    required this.success,
    this.latencyMs,
  });

  final int sequence;
  final bool success;
  final int? latencyMs;

  Map<String, dynamic> toJson() => {
    'sequence': sequence,
    'success': success,
    'latencyMs': latencyMs,
  };

  factory PingResultModel.fromJson(Map<String, dynamic> json) {
    return PingResultModel(
      sequence: json['sequence'] as int,
      success: json['success'] as bool,
      latencyMs: json['latencyMs'] as int?,
    );
  }
}
