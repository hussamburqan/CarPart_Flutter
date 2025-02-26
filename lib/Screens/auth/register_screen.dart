import 'package:flutter/material.dart';
import '../../Services/auth_service.dart';
import '../../Services/localizations.dart';
import '../../apptheme.dart';
import '../components/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailVerified = false;
  String? _verificationCode;
  bool _isVerifyingEmail = false;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate() || !_isEmailVerified) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();

      await authService.register(context: context,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleVerifyEmail() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.translate('valid_email')!);
      return;
    }

    setState(() {
      _isVerifyingEmail = true;
      _errorMessage = null;
    });

    try {
      final authService = AuthService();
      await authService.sendVerificationCodeReg( context: context,email: _emailController.text.trim());

      setState(() {
        _isVerifyingEmail = false;
        _isEmailVerified = false;
      });

      _showVerificationDialog();

    } catch (e) {
      setState(() {
        _isVerifyingEmail = false;
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    }
  }

  Future<void> _showVerificationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate('verification_code_0')!),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.translate('verification_code_1')!),
                const SizedBox(height: 16),
                TextField(
                  controller: _verificationCodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.translate('verification_code_2')!,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _verificationCode = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.translate('cancel')!),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.translate('verify')!),
              onPressed: () async {
                if (_verificationCode != null && _verificationCode!.isNotEmpty) {
                  setState(() => _isLoading = true);
                  try {
                    final authService = AuthService();
                    final isCodeValid = await authService.verifyEmail(context: context,
                      email: _emailController.text.trim(),
                      verificationCode: _verificationCode!.trim(),
                    );
                    if (isCodeValid) {
                      setState(() {
                        _isEmailVerified = true;
                        _errorMessage = null;
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.translate('email_verified')!)),
                      );
                    } else {
                      setState(() {
                        _errorMessage = AppLocalizations.of(context)!.translate('invalid_verification')!;
                        _isLoading = false;
                      });
                    }
                  } catch (e) {
                    setState(() {
                      _errorMessage = e.toString().replaceAll('Exception:', '').trim();
                      _isLoading = false;
                    });
                  }
                } else {
                  setState(() {
                    _errorMessage = AppLocalizations.of(context)!.translate('please_enter_the_verification_code')!;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 48),
                  Text(
                    AppLocalizations.of(context)!.translate('create_account')!,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48),
                  CustomTextField(
                    controller: _usernameController,
                    label: AppLocalizations.of(context)!.translate('username')!,
                    prefixIcon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                    validator: (value) => value!.isEmpty ? AppLocalizations.of(context)!.translate('username_is_required')! : null,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _emailController,
                          label: AppLocalizations.of(context)!.translate('email')!,
                          prefixIcon: Icons.email_outlined,
                          textInputAction: TextInputAction.next,
                          validator: (value) => !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)
                              ? AppLocalizations.of(context)!.translate('email_a_valid')!
                              : null,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () async {
                          await _handleVerifyEmail();
                        },
                      ),
                    ],
                  ),
                  if (!_isEmailVerified)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(AppLocalizations.of(context)!.translate('email_verify')!, style: TextStyle(color: Colors.red)),
                    ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    label: AppLocalizations.of(context)!.translate('phone')!,
                    prefixIcon: Icons.phone_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (value) => value!.length != 9 ? AppLocalizations.of(context)!.translate('phone_valid')! : null,
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: AppLocalizations.of(context)!.translate('password')!,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) return AppLocalizations.of(context)!.translate('password_is_req')!;
                      if (value.length < 8) return  AppLocalizations.of(context)!.translate('password_must_be')!;
                      if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).+$').hasMatch(value)) {
                        return AppLocalizations.of(context)!.translate('password_must_include')!;
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: AppLocalizations.of(context)!.translate('confirm_password')!,
                    prefixIcon: Icons.lock_outline,
                    textInputAction: TextInputAction.done,
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => value != _passwordController.text ? AppLocalizations.of(context)!.translate('password_do_not_match')! : null,
                    suffixIcon: IconButton(
                      icon:
                      Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:_isLoading ? null :_handleRegister,
                    child:_isLoading ? CircularProgressIndicator() : Text(AppLocalizations.of(context)!.translate('register')!),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child:
                      Container(padding:
                      const EdgeInsets.all(12), decoration:
                      BoxDecoration(color:
                      AppTheme.errorColor.withOpacity(0.1), borderRadius:
                      BorderRadius.circular(8),), child:
                      Text(_errorMessage!, style:
                      const TextStyle(color:
                      AppTheme.errorColor, fontSize:
                      14,), textAlign:
                      TextAlign.center,)),
                    ),
                  SizedBox(height:
                  16),
                  TextButton(onPressed:
                      () { Navigator.pushReplacementNamed(context, '/login'); },
                      child:
                      Text('${AppLocalizations.of(context)!.translate('already_have_acc')!} ${AppLocalizations.of(context)!.translate('login')!}')),
                ],
              ),
            ),
          ),
        )
    );
  }
}