import 'dart:async';
import 'package:flutter/material.dart';
import '../../otp_cascade.dart';

class OtpCascadePushPrompt extends StatefulWidget {
  final String userId;
  final VoidCallback onApproved;
  final Function(String error) onFailed;
  final VoidCallback onFallbackSms;

  const OtpCascadePushPrompt({
    super.key,
    required this.userId,
    required this.onApproved,
    required this.onFailed,
    required this.onFallbackSms,
  });

  @override
  State<OtpCascadePushPrompt> createState() => _OtpCascadePushPromptState();
}

class _OtpCascadePushPromptState extends State<OtpCascadePushPrompt> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  int _secondsRemaining = 180; // 3 minutes TTL
  Timer? _timer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _timer?.cancel();
        });
        widget.onFallbackSms();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  String get _timerString {
    final minutes = (_secondsRemaining / 60).floor().toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _verifyOtp() async {
    final String otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await OtpCascade.verifyPushOtp(
      userId: widget.userId,
      otp: otp,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      _timer?.cancel();
      Navigator.of(context).pop();
      widget.onApproved();
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'Tasdiqlash kodi xato';
        // Clear pins
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      });

      if (result['fallback'] == true) {
        _timer?.cancel();
        Navigator.of(context).pop();
        widget.onFallbackSms();
      }
    }
  }

  void _onPinChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp(); // Auto-verify on last digit
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF0D9488); // Teal style

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: MainLifecycleColumn(
        primaryColor: primaryColor,
        timerString: _timerString,
        controllers: _controllers,
        focusNodes: _focusNodes,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onPinChanged: _onPinChanged,
        onFallbackSms: widget.onFallbackSms,
      ),
    );
  }
}

class MainLifecycleColumn extends StatelessWidget {
  final Color primaryColor;
  final String timerString;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isLoading;
  final String? errorMessage;
  final Function(int, String) onPinChanged;
  final VoidCallback onFallbackSms;

  const MainLifecycleColumn({
    super.key,
    required this.primaryColor,
    required this.timerString,
    required this.controllers,
    required this.focusNodes,
    required this.isLoading,
    required this.errorMessage,
    required this.onPinChanged,
    required this.onFallbackSms,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Tasdiqlash kodi',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Smartfoningizga yuborilgan 6 xonali tasdiqlash kodini kiriting',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 28),
        
        // OTP Inputs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: "",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                onChanged: (value) => onPinChanged(index, value),
              ),
            );
          }),
        ),
        
        const SizedBox(height: 20),
        
        if (errorMessage != null) ...[
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
          const SizedBox(height: 12),
        ],

        // Timer and Resend option
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_outlined, size: 16, color: primaryColor),
            const SizedBox(width: 4),
            Text(
              timerString,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onFallbackSms();
            },
            child: Text(
              'Kod kelmadimi? SMS orqali yuborish',
              style: TextStyle(color: Colors.grey[600], decoration: TextDecoration.underline),
            ),
          ),
      ],
    );
  }
}
