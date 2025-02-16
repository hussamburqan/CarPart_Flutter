import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../apptheme.dart';
import '../services/auth_service.dart';
import 'components/custom_button.dart';

class VerificationCodePage extends StatefulWidget {
  const VerificationCodePage({Key? key}) : super(key: key);

  @override
  _VerificationCodePageState createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
        (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
        (_) => FocusNode(),
  );

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  String username = '';
  String serverChallenge = '';
  String challengecreatedat = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromArguments();
    });

    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  void _initializeFromArguments() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      setState(() {
        _errorMessage = 'Missing authentication data';
      });
      return;
    }

    final username = args['username'] as String?;
    final serverChallenge = args['serverChallenge'] as String?;
    final challengecreatedat = args['challengecreatedat'] as String?;

    if (username == null || serverChallenge == null) {
      setState(() {
        _errorMessage = 'Missing required authentication data';
      });
      return;
    }

    setState(() {
      this.username = username;
      this.serverChallenge = serverChallenge;
      this.challengecreatedat = challengecreatedat!;
      _isInitialized = true;
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify2FA() async {
    if (!_isInitialized) {
      setState(() {
        _errorMessage = 'Authentication data not initialized';
      });
      return;
    }

    if (_code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.verify2FA(
        username: username,
        serverChallenge: serverChallenge,
        challenge_created_at: challengecreatedat,
        totp: _code,
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verification'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter verification code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please enter the 6-digit from authenticator app',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.subtitleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 48,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                        if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_code.length == 6) {
                          _verify2FA();
                        }
                      },
                    ),
                  );
                }),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomButton(
                  onPressed: _verify2FA,
                  text: 'Verify',
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}