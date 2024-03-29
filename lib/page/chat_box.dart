import 'package:flutter/material.dart';
import 'package:omjh/bloc/chat_box_bloc.dart';
import 'package:omjh/common/theme_style.dart';
import 'package:get/get.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({super.key});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final ChatBoxBloc _bloc = ChatBoxBloc();
  final _messageControl = TextEditingController();

  @override
  void initState() {
    super.initState();

    _bloc.init();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 24,
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              backgroundColor: ThemeStyle.bgColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18))),
          onPressed: () {
            if (_messageControl.text.isEmpty) {
              return;
            }
            _bloc.sendMessage(_messageControl.text);
            _messageControl.text = '';
          },
          child: Text(
            'submit'.tr,
            style: ThemeStyle.textStyle
                .copyWith(color: Colors.white, fontSize: 16),
          )),
    );
  }

  Widget _buildMessage(int index) {
    final message = _bloc.messages[index];
    String text = '[${message.charName}]: ${message.content}';
    return Text(text, style: ThemeStyle.textStyle.copyWith(fontSize: 16));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height / 5.0;
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
                          bottom: BorderSide(
                              width: 1.5, color: ThemeStyle.bgColor))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Obx(() => ListView.builder(
                        itemCount: _bloc.messages.length,
                        itemBuilder: ((context, index) {
                          return _buildMessage(index);
                        }))),
                  ))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  style: ThemeStyle.textStyle.copyWith(fontSize: 16),
                  decoration: InputDecoration(
                      hintText: 'input_dialog'.tr,
                      hintStyle: ThemeStyle.textStyle.copyWith(fontSize: 16),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 5)),
                  controller: _messageControl,
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
