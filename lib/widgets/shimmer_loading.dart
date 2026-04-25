// File: lib/widgets/shimmer_loading.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MatchShimmerLoading extends StatelessWidget {
  const MatchShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: 6, // Hiển thị 6 cái thẻ loading giả
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 0, // Loading thì không cần đổ bóng
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!), // Viền mờ mờ
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 12.0,
            ),
            // Bọc toàn bộ nội dung trong Shimmer để tạo hiệu ứng lấp lánh chạy ngang
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!, // Màu xám gốc
              highlightColor: Colors.grey[100]!, // Màu vệt sáng lướt qua
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Khung xương đội nhà
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(width: 60, height: 10, color: Colors.white),
                      ],
                    ),
                  ),

                  // Khung xương tỉ số
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Container(width: 50, height: 24, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 40, height: 10, color: Colors.white),
                      ],
                    ),
                  ),

                  // Khung xương đội khách
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(width: 60, height: 10, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
