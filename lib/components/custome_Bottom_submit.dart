// ignore: file_names
import 'package:flutter/material.dart';

class CustomButtonSubmit extends StatefulWidget {
  final VoidCallback? onPressed;
  final String? leadingIcon;
  final Widget? leadingIconWidget;
  final double? iconSize;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double borderWidth;
  final double fontSize;
  final bool isLoading;
  final double elevation;

  const CustomButtonSubmit({
    super.key,
    required this.onPressed,
    this.leadingIcon,
    this.leadingIconWidget,
    this.iconSize = 20,
    required this.label,
    this.backgroundColor = const Color(0xFF27bdc3),
    this.borderColor = Colors.transparent,
    this.textColor = Colors.white,
    this.borderRadius = 10.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.borderWidth = 1.5,
    this.fontSize = 16,
    this.isLoading = false,
    this.elevation = 0,
  });

  @override
  State<CustomButtonSubmit> createState() => _CustomButtonSubmitState();
}

class _CustomButtonSubmitState extends State<CustomButtonSubmit> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        padding: widget.padding,
        elevation: widget.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          side: BorderSide(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
        ),
      ),
      child:
          widget.isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.leadingIconWidget != null) ...[
                    widget.leadingIconWidget!,
                    const SizedBox(width: 16),
                  ] else if (widget.leadingIcon != null &&
                      widget.leadingIcon!.isNotEmpty) ...[
                    Image.asset(
                      widget.leadingIcon!,
                      color: widget.textColor,
                      height: widget.iconSize,
                      width: widget.iconSize,
                    ),
                    const SizedBox(width: 16),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.textColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      fontSize: widget.fontSize,
                    ),
                  ),
                ],
              ),
    );
  }
}
