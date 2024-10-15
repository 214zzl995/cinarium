import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../components/scroll_animator.dart';
import '../controllers/settings_controller.dart';

class ThreadCountSetting extends StatelessWidget {
  const ThreadCountSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(6),
          ),
          border: Border.all(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Icon(
                      Symbols.stacks,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Number of threads',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                )),
          ],
        ));
  }
}
