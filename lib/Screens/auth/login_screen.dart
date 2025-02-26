import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../apptheme.dart';
import '../../Services/localizations.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false    ;
        _errorMessage = AppLocalizations.of(context)!.translate('please_fill_all')!;
      });

      return;
    }

    try {
      final loginResponse = await _authService.login(
        context: context,
        username: username,
        password: password,
      );

      if (!mounted) return;
      if (loginResponse.requires2FA) {
        Navigator.pushNamed(
          context,
          '/2fa',
          arguments: {
            'username': username,
            'password': password,
            'serverChallenge': loginResponse.serverChallenge,
            'challengecreatedat': loginResponse.challengecreatedat,
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e
            .toString()
            .replaceAll('Exception:', '')
            .trim();
      });
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
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.translate('app_title')!,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.translate('app_subtitle')!,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              Row(
                children: [

                PopupMenuButton<String>(
                      icon: const Icon(Icons.translate, color: Colors.black),
                      onSelected: (String newLang) async {
                        if (newLang != null) {
                          languageProvider.changeLanguage(newLang);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'en',
                          child: Row(
                            children: [
                              const Icon(Icons.translate, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(AppLocalizations.of(context)!.translate('english')!),
                            ],
                          ),
                        ),

                        PopupMenuItem(
                          value: 'ar',
                          child: Row(
                            children: [
                              const Icon(Icons.translate, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(AppLocalizations.of(context)!.translate('arabic')!),
                            ],
                          ),
                        ),
                      ],
                    ),

                  Spacer(),
                ],
              ),

              CustomTextField(
                controller: _usernameController,
                label: AppLocalizations.of(context)!.translate('username')!,
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: AppLocalizations.of(context)!.translate('password')!,
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: () => _login(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.subtitleColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot_password');
                    },
                    child: Text(
                      AppLocalizations.of(context)!.translate("forgot_password")!,
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 16),
                    ),
                  ),
                ],
              ),
              CustomButton(
                onPressed: _login,
                text: AppLocalizations.of(context)!.translate('login')!,
                isLoading: _isLoading,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  '${AppLocalizations.of(context)!.translate("don't_have_acc")!} ${AppLocalizations.of(context)!.translate('register')!}',
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 16),
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
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}