import 'package:HYBRID_APP/extensions/StringExtension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../configs/config/config.dart';
import '../customs/custom.dart';
import '../providers/permission_provider.dart';

class PermissionCheckPage extends ConsumerWidget {

  static const String routeName = "/permission_check_page";
  static const String path = "/permission/check/page";

  const PermissionCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(PADDING_VALUE),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: PADDING_VALUE),
              Text("하이브리드앱을 이용하기 위해서 아래의 권한이 필요합니다".insertZwj(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center),
              const SizedBox(height: PADDING_VALUE),
              _buildButton("사진(필수)", const Text("게시글, 댓글 이미지 업로드")),
              const SizedBox(height: PADDING_VALUE),
              _buildButton("알림(필수)", const Text("이벤트 알림, 기타 알림")),
              const SizedBox(height: PADDING_VALUE),
              CupertinoButton(
                color: CustomColors.main,
                onPressed: ref.read(permissionProvider.notifier).requestPermissions,
                child: const Center(child: Text("확인", style: TextStyle(fontWeight: FontWeight.bold))),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String title, Widget subtitle) {
    return ListTile(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
      ),
      tileColor: Colors.white,
      title: Text(title, style: const TextStyle(color: CustomColors.main, fontWeight: FontWeight.bold)),
      subtitle: subtitle,
    );
  }
}
