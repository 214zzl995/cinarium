import 'package:flutter/cupertino.dart';

class FileCol extends StatelessWidget {
  const FileCol({super.key, this.flex, this.width, required this.value})
      : assert(!(flex != null && width != null),
            'flex and width cannot be used together'),
        assert(flex != null || width != null,
            'At least one of flex and width must be provided'),
        super();

  final int? flex;

  final double? width;

  final dynamic value;

  @override
  Widget build(BuildContext context) {
    if (flex != null) {
      return Expanded(
        flex: flex!,
        child: _buildValue(),
      );
    } else if (width != null) {
      return SizedBox(
        width: width,
        child: Center(
          child: _buildValue(),
        ),
      );
    }
    throw UnimplementedError();
  }

  Widget _buildValue() {
    if (value is int) return Text(value.toString());
    if (value is double) return Text(value.toString());
    if (value is String) return Text(value);
    if (value is Widget) return value;
    throw UnimplementedError("Unknown value type");
  }
}
