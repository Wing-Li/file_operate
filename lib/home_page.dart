import 'dart:io';

import 'package:file_operate/utils/my_utils.dart';
import 'package:file_operate/utils/sp_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const ORIGINAL_PATH = "original_path";
const TARGET_PATH = "target_path";

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController originalTextEditingController = TextEditingController();
  TextEditingController targetTextEditingController = TextEditingController();
  String logMsg = "";

  @override
  void initState() {
    super.initState();

    originalTextEditingController.text = SpUtil.getString(ORIGINAL_PATH) ?? "";
    targetTextEditingController.text = SpUtil.getString(TARGET_PATH) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("文件转移"),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              "功能： 将 '原始路径' 的目录下所有视频文件统一移动到 '目标路径' 。",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              child: _itemText("原始路径: ", originalTextEditingController, Icons.file_open_outlined),
              onTap: () async {
                String? result = await FilePicker.platform.getDirectoryPath(dialogTitle: "选择路径");
                if (result != null) {
                  SpUtil.putString(ORIGINAL_PATH, result);
                  originalTextEditingController.text = result ?? "";
                }
              },
            ),
            const SizedBox(height: 20),
            GestureDetector(
              child: _itemText("目标路径: ", targetTextEditingController, Icons.file_open_outlined),
              onTap: () async {
                String? result = await FilePicker.platform.getDirectoryPath(dialogTitle: "选择路径");
                if (result != null) {
                  SpUtil.putString(TARGET_PATH, result);
                  targetTextEditingController.text = result ?? "";
                }
              },
            ),
            const SizedBox(height: 20),
            if (!MyUtils.isEmpty(logMsg))
              SizedBox(
                height: 120,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6D6D6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      logMsg,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 26),
            FilledButton(
              child: const Text("开始转移"),
              onPressed: () {
                if (originalTextEditingController.text.trim().isEmpty) {
                  MyUtils.showToast("原始路径不能为空");
                  return;
                }
                if (targetTextEditingController.text.trim().isEmpty) {
                  MyUtils.showToast("目标路径不能为空");
                  return;
                }
                movList();
              },
            ),
          ],
        ),
      ),
    );
  }

  // 返回Row 左边为标题 右边为输入框
  _itemText(String title, TextEditingController controller, IconData icon) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              controller: controller,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 32),
      ],
    );
  }

  void movList() async {
    String originalPathPath = originalTextEditingController.text.trim();
    String targetPathPath = targetTextEditingController.text.trim();
    Directory filePath = Directory(originalPathPath);
    List<FileSystemEntity> listFiles = filePath.listSync();
    for (FileSystemEntity file in listFiles) {
      if ((await File(file.path).stat()).type != FileSystemEntityType.directory) {
        continue;
      }

      List<FileSystemEntity> childFileList = Directory(file.path).listSync();
      for (var childFile in childFileList) {
        if (childFile.path.toLowerCase().endsWith(".mp4") ||
            childFile.path.toLowerCase().endsWith(".mkv") ||
            childFile.path.toLowerCase().endsWith(".flv") ||
            childFile.path.toLowerCase().endsWith(".avi") ||
            childFile.path.toLowerCase().endsWith(".rmvb") ||
            childFile.path.toLowerCase().endsWith(".wmv") ||
            childFile.path.toLowerCase().endsWith(".mov") ||
            childFile.path.toLowerCase().endsWith(".ts")) {
          moveFile(childFile.path, "$targetPathPath/${MyUtils.getPathFileName(childFile.path)}");
        }
      }
    }
  }

  void moveFile(String startPath, String endPath) async {
    try {
      File startFile = File(startPath);
      File endFile = File(endPath);
      if (!(await endFile.exists())) {
        await endFile.create();
      }

      File newEndFile = await startFile.rename(endPath);
      String msg = "";
      if (await newEndFile.exists()) {
        msg = "文件移动成功！目标路径：$endPath\n";
      } else {
        msg = "文件移动失败！目标路径：$endPath\n";
      }
      logMsg += msg;
      setState(() {});
    } catch (e) {
      MyUtils.log(e);
    }
  }
}
