import 'package:flutter/material.dart';
import 'package:cinarium/screens/hfs/components/serve_ip_bar.dart';
import '../components/hfs_button.dart';

class HfsPage extends StatelessWidget {
  const HfsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(children: [
          Row(
            children: [
              const HfsButton(),
              Expanded(
                  child: Container(
                alignment: Alignment.centerLeft,
                height: 60,
                padding: const EdgeInsets.all(5.0),
                margin: const EdgeInsets.only(left: 15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const ServeIpBar(),
              )),
            ],
          ),
          Expanded(
              child: Container(
            height: 80,
            padding: const EdgeInsets.all(5.0),
            margin: const EdgeInsets.only(top: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
            child: const Center(
              child: Text("日志，暂不在开发计划"),
            ),
          ))
        ]),
      ),
    );
  }
}
