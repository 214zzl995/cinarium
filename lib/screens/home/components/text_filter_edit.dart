import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinarium/screens/home/controllers/home_controller.dart';

class TextFilterEdit extends StatelessWidget {
  const TextFilterEdit({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Container(
        width: 300,
        margin: const EdgeInsets.only(right: 13),
        child: SizedBox(
            height: 38,
            child: TextField(
              cursorHeight: 22,
              cursorWidth: 3,
              controller: searchController,
              cursorOpacityAnimates: true,
              style: const TextStyle(
                fontSize: 14,
              ),
              onChanged: (value) {
                context.read<HomeController>().addTextFilter(value);
              },
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                    left: 10,
                  ),
                  border: const OutlineInputBorder(),
                  label: Text(
                    '',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  )),
            )),
      )
    ]);
  }
}
