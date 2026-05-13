class InventoryBucketBalance {
  const InventoryBucketBalance({required this.bucket, required this.balance});

  final String bucket;
  final String balance;

  factory InventoryBucketBalance.fromJson(Map<String, dynamic> json) {
    return InventoryBucketBalance(
      bucket: json['bucket']?.toString() ?? '',
      balance: json['balance']?.toString() ?? '0',
    );
  }
}
