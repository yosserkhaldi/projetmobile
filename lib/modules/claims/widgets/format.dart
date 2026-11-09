String _two(int value) => value.toString().padLeft(2, '0');

String formatDay(DateTime date) =>
    '${_two(date.day)}/${_two(date.month)}/${date.year}';

String formatDateTime(DateTime date) =>
    '${formatDay(date)} ${_two(date.hour)}:${_two(date.minute)}';
