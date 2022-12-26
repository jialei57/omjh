import 'package:flutter/material.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:get/get.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({super.key});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  Widget _buildSubmitButton() {
    return SizedBox(
      height: 30,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              backgroundColor: ThemeStyle.bgColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18))),
          onPressed: () {},
          child: Text(
            'submit'.tr,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height / 4.5;
    return Container(
      height: height,
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(width: 1.5, color: ThemeStyle.bgColor),
              bottom: BorderSide(width: 1, color: ThemeStyle.bgColor))),
      child: Column(
        children: [
          Expanded(
              child: Container(
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(width: 1.5, color: ThemeStyle.bgColor))),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(hintText: 'input_dialog'.tr),
                )),
                _buildSubmitButton()
              ],
            ),
          )
        ],
      ),
    );
  }
}
