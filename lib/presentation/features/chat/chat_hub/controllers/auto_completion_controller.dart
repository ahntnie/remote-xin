import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _usernamePrefix = '@';

mixin TextWithCompletionController on GetxController {
  final TextEditingController textEditingController = TextEditingController();

  bool enableAutoCompletion = true;

  @override
  void onInit() {
    textEditingController.addListener(_checkForAutoCompletion);
    super.onInit();
  }

  @override
  void onClose() {
    textEditingController.removeListener(_checkForAutoCompletion);
    super.onClose();
  }

  void search(String query);
  void turnOffAutoCompleting();

  void _checkForAutoCompletion() {
    if (!enableAutoCompletion) {
      return;
    }

    final result = checkTextForAutocompletion();

    if (result.isAutoCompleting) {
      search(result.autoCompleteQuery!);
    } else {
      turnOffAutoCompleting();
    }
  }

  TextAutocompletionResult checkTextForAutocompletion() {
    final int cursorPosition = textEditingController.selection.baseOffset;

    if (cursorPosition >= 1) {
      final String lastWord =
          _getWordBeforeCursor(textEditingController.text, cursorPosition);

      if (lastWord.startsWith(_usernamePrefix)) {
        final String searchQuery = lastWord.substring(_usernamePrefix.length);

        return TextAutocompletionResult(
          isAutoCompleting: true,
          autoCompleteQuery: searchQuery,
        );
      }
    }

    return TextAutocompletionResult(isAutoCompleting: false);
  }

  String _getWordBeforeCursor(String text, int cursorPosition) {
    if (text.isNotEmpty) {
      final start = text.lastIndexOf(RegExp(r'\s'), cursorPosition - 1);

      return text.substring(start + 1, cursorPosition);
    } else {
      return text;
    }
  }

  void autocompleteTextWithUsername(
    TextEditingController textController,
    String username,
  ) {
    _autocompleteText(
      textController,
      username,
      _usernamePrefix,
      () =>
          throw 'Tried to autocomplete text with username without $_usernamePrefix',
    );
  }

  void _autocompleteText(
    TextEditingController textController,
    String value,
    String prefix,
    VoidCallback onPrefixMissing,
  ) {
    final text = textController.text;
    final cursorPosition = textController.selection.baseOffset;
    final lastWord = _getWordBeforeCursor(text, cursorPosition);

    if (!lastWord.startsWith(prefix)) {
      onPrefixMissing();
    }

    final newTextStart =
        '${text.substring(0, cursorPosition - lastWord.length)}$prefix$value ';
    final newTextEnd = text.substring(cursorPosition);
    final newSelection = TextSelection.collapsed(offset: newTextStart.length);

    textController.value = TextEditingValue(
      text: newTextStart + newTextEnd,
      selection: newSelection,
    );
  }
}

class TextAutocompletionResult {
  final bool isAutoCompleting;
  final String? autoCompleteQuery;

  TextAutocompletionResult({
    required this.isAutoCompleting,
    this.autoCompleteQuery,
  });
}
