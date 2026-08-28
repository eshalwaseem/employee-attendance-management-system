import 'package:flutter/material.dart';

class EmailField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool isValid;
  final bool hasError;
  final String? errorText;
  final VoidCallback? onSubmitted;

  const EmailField({
    super.key,
    required this.controller,
    this.onChanged,
    this.isValid = false,
    this.hasError = false,
    this.errorText,
    this.onSubmitted,
  });

  @override
  State<EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<EmailField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email address is required.';
    }

    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!isValid) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final borderColor = widget.hasError
        ? colorScheme.error
        : _focusNode.hasFocus
        ? colorScheme.primary
        : Colors.transparent;

    final shadowColor = widget.hasError
        ? colorScheme.error.withValues(alpha: 0.10)
        : _focusNode.hasFocus
        ? colorScheme.primary.withValues(alpha: 0.12)
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: _focusNode.hasFocus || widget.hasError ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: _focusNode.hasFocus ? 18 : 0,
            spreadRadius: _focusNode.hasFocus ? 1 : 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateEmail,
          onChanged: widget.onChanged,
          onFieldSubmitted: (_) {
            widget.onSubmitted?.call();
          },
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            filled: false,
            hintText: 'Email address',
            prefixIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.only(left: 16),
              child: Icon(
                Icons.mail_outline_rounded,
                color: _focusNode.hasFocus
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 54),
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: widget.isValid
                  ? Icon(
                      Icons.check_circle_rounded,
                      key: const ValueKey('valid'),
                      color: colorScheme.tertiary,
                    )
                  : widget.hasError
                  ? Icon(
                      Icons.error_outline_rounded,
                      key: const ValueKey('error'),
                      color: colorScheme.error,
                    )
                  : const SizedBox(key: ValueKey('empty')),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 54),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            errorStyle: TextStyle(
              color: colorScheme.error,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
