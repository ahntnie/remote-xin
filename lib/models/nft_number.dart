class NftNumber {
  final String id;
  final int? userTemp;
  final String? esim;
  final bool? isGift;
  final bool? isEsim;
  final String? comment;
  final bool? isCombo;
  final bool? isDefault;
  final int? status;
  final String number;
  final int? nftId;
  final DateTime createdAt;

  NftNumber({
    required this.id,
    required this.number,
    required this.createdAt,
    this.userTemp,
    this.isGift,
    this.isEsim,
    this.comment,
    this.isCombo,
    this.isDefault,
    this.status,
    this.nftId,
    this.esim,
  });

  factory NftNumber.fromJson(Map<String, dynamic> json) {
    return NftNumber(
      id: json['id'] ?? '',
      userTemp: json['userTemp'] ?? 0,
      esim: json['esim'],
      isGift: json['isGift'] ?? false,
      isEsim: json['isEsim'] ?? false,
      comment: json['comment'] ?? '',
      isCombo: json['isCombo'] ?? false,
      isDefault: json['isDefault'] ?? false,
      status: json['status'] ?? 0,
      number: json['number'] ?? '',
      nftId: json['nftId'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userTemp': userTemp,
      'esim': esim,
      'isGift': isGift,
      'isEsim': isEsim,
      'comment': comment,
      'isCombo': isCombo,
      'isDefault': isDefault,
      'status': status,
      'number': number,
      'nftId': nftId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copy with method for creating copies with modified fields
  NftNumber copyWith({
    String? id,
    int? userTemp,
    String? esim,
    bool? isGift,
    bool? isEsim,
    String? comment,
    bool? isCombo,
    bool? isDefault,
    int? status,
    String? number,
    int? nftId,
    DateTime? createdAt,
  }) {
    return NftNumber(
      id: id ?? this.id,
      userTemp: userTemp ?? this.userTemp,
      esim: esim ?? this.esim,
      isGift: isGift ?? this.isGift,
      isEsim: isEsim ?? this.isEsim,
      comment: comment ?? this.comment,
      isCombo: isCombo ?? this.isCombo,
      isDefault: isDefault ?? this.isDefault,
      status: status ?? this.status,
      number: number ?? this.number,
      nftId: nftId ?? this.nftId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static List<NftNumber> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => NftNumber.fromJson(json)).toList();
  }

  NftNumber.empty()
      : id = '',
        userTemp = null,
        esim = null,
        isGift = null,
        isEsim = null,
        comment = null,
        isCombo = null,
        isDefault = null,
        status = null,
        number = '',
        nftId = null,
        createdAt = DateTime.now();
}
