import 'dart:convert';
import 'package:carparts/Screens/verify_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../Services/TowFactorAuth.dart';
import '../Services/localizations.dart'; // Import your localization service

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TwoFactorAuthService _authService;
  bool _is2FAEnabled = false;
  String? _qrCodeData;
  bool _isLoading = false;
  bool _isLoadingSeller = false;
  bool _isQRCodeVisible = false;
  final _authBox = Hive.box('auth');

  @override
  void initState() {
    super.initState();
    _authService = TwoFactorAuthService();
    _check2FAStatus();
  }

  Future<void> _setup2FA() async {
    setState(() => _isLoading = true);

    try {
      final response = await _authService.setup2FA(context);

      setState(() => _isLoading = false);

      if (response != null) {
        final verified = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationPage(),
          ),
        );

        if (verified == true) {
          _check2FAStatus();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.translate('failed_initiate_2fa')!)),
        );
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _check2FAStatus() async {
    try {
      setState(() => _isLoading = true);
      final response = await _authService.verify2FA(context);
      if (response != null && response.containsKey('qr_code')) {
        setState(() {
          _qrCodeData = response['qr_code'];
          _is2FAEnabled = true;
        });
      } else {
        setState(() {
          _is2FAEnabled = false;
        });
      }
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.translate('failed_check_2fa_status')!);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _disable2FA() async {
    try {
      setState(() => _isLoading = true);
      final success = await _authService.disable2FA(context);
      if (success) {
        setState(() {
          _qrCodeData = null;
          _is2FAEnabled = false;
          _isQRCodeVisible = false;
        });
        _showSnackBar(AppLocalizations.of(context)!.translate('2fa_disabled_successfully')!, isError: false);
      } else {
        _showSnackBar(AppLocalizations.of(context)!.translate('failed_disable_2fa')!);
      }
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _upgradeToseller() async {
    try {
      setState(() => _isLoadingSeller = true);
      await Future.delayed(const Duration(seconds: 2));
      _showSnackBar(AppLocalizations.of(context)!.translate('seller_upgrade_request_submitted')!, isError: false);
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      setState(() => _isLoadingSeller = false);
    }
  }

  Future<void> _showQRCodeWithPassword() async {
    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate('enter_password_to_view_qr_code')!),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.translate('password')!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.translate('cancel')!),
            ),
            TextButton(
              onPressed: () async {
                final password = passwordController.text;
                if (password.isNotEmpty) {
                  try {
                    final success = await _authService.verifyPassword(password, context);
                    if (success) {
                      setState(() {
                        _isQRCodeVisible = true;
                      });
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      _showSnackBar(AppLocalizations.of(context)!.translate('incorrect_password')!);
                    }
                  } catch (e) {
                    _showSnackBar(AppLocalizations.of(context)!.translate('failed_verify_password')!);
                  }
                } else {
                  _showSnackBar(AppLocalizations.of(context)!.translate('please_enter_password')!);
                }
              },
              child: Text(AppLocalizations.of(context)!.translate('confirm')!),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    final color = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text(
          AppLocalizations.of(context)!.translate('profile_settings')!,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Security Section
            _buildSectionHeader(
              icon: Icons.security_rounded,
              title: AppLocalizations.of(context)!.translate('security_settings')!,
            ),
            const SizedBox(height: 16),
            _build2FACard(),
            const SizedBox(height: 24),

            // Account Section
            _buildSectionHeader(
              icon: Icons.store_rounded,
              title: AppLocalizations.of(context)!.translate('account_settings')!,
            ),
            const SizedBox(height: 16),
            _buildSellerCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _build2FACard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    color: _is2FAEnabled ? Colors.green : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.translate('two_factor_authentication')!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _is2FAEnabled ? AppLocalizations.of(context)!.translate('enabled')! : AppLocalizations.of(context)!.translate('disabled')!,
                          style: TextStyle(
                            color: _is2FAEnabled ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_is2FAEnabled && _isQRCodeVisible && _qrCodeData != null) ...[
                Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.memory(
                      base64Decode(_qrCodeData!.split(',').last),
                      height: 200,
                      width: 200,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.translate('scan_qr_code_with_authenticator_app')!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ] else if (_is2FAEnabled) ...[
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _showQRCodeWithPassword,
                    icon: Icon(Icons.qr_code_rounded, color: Colors.white),
                    label: Text(AppLocalizations.of(context)!.translate('show_qr_code')!),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : (_is2FAEnabled ? _disable2FA : _setup2FA),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _is2FAEnabled ? Colors.red.shade400 : Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    _is2FAEnabled ? AppLocalizations.of(context)!.translate('disable_2fa')! : AppLocalizations.of(context)!.translate('enable_2fa')!,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellerCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.orange.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.store_rounded, color: Colors.orange.shade700, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.translate('seller_account')!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _authBox.get('role') != 'seller'
                  ? Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.translate('upgrade_to_seller_description')!,
                        style: TextStyle(
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : SizedBox.shrink(),
              const SizedBox(height: 20),
              _authBox.get('role') != 'seller'
                  ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoadingSeller ? null : _upgradeToseller,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoadingSeller
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle_outlined, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.translate('upgrade_to_seller')!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.orange.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.orange.shade600, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.translate('you_are_subscribed')!,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}