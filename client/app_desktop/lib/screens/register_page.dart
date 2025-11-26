import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_desktop/app_state.dart';
import 'package:app_desktop/l10n/app_localizations.dart';
import 'package:app_desktop/src/rust/api/config_api.dart' as config_api;
import 'package:app_desktop/src/rust/api/reg_api.dart' as reg_api;
import 'package:app_desktop/src/rust/api/reg_api_types.dart';
import 'package:app_desktop/src/rust/api/user_api.dart' as user_api;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'CN');
  final _languageCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  String? _genderKey;
  int _genderValue = 0;
  bool _sendingCode = false;
  bool _verifying = false;
  String? _regId;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _countryCtrl.dispose();
    _languageCtrl.dispose();
    _nicknameCtrl.dispose();
    _codeCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _pickNicknameByGender(String? genderKey) async {
    try {
      final nick = await user_api.randomNickname(gender: genderKey);
      if (mounted) {
        _nicknameCtrl.text = nick;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取随机昵称失败: $e')),
        );
      }
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown -= 1);
      }
    });
  }

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailCtrl.text.trim();
    final pwd = _passwordCtrl.text;
    if (email.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.email)),
      );
      return;
    }
    setState(() => _sendingCode = true);
    try {
      final req = BuildRegisterCodeRequest(
        password: pwd,
        target: email,
        language: _languageCtrl.text.trim().isEmpty
            ? null
            : _languageCtrl.text.trim(),
        country:
            _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
        gender: _genderValue == 0 ? null : _genderValue,
        nickname: _nicknameCtrl.text.trim().isEmpty
            ? null
            : _nicknameCtrl.text.trim(),
      );
      final res = await reg_api.buildRegisterCode(payload: req);
      setState(() => _regId = res.regId);
      _startCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.sendCode)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('send failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context)!;
    if (_regId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sendCode)),
      );
      return;
    }
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.verificationCode)),
      );
      return;
    }
    setState(() => _verifying = true);
    try {
      await reg_api.verifyRegisterCode(
        payload: VerifyRegisterCodeRequest(regId: _regId!, code: code),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.register)),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('verify failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.register),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _countryCtrl,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: l10n.country,
                          prefixIcon: const Icon(Icons.flag_outlined),
                          suffixIcon: PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down),
                            onSelected: (val) {
                              _countryCtrl.text = val;
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'CN',
                                child: Text('China (CN)'),
                              ),
                              PopupMenuItem(
                                value: 'US',
                                child: Text('United States (US)'),
                              ),
                              PopupMenuItem(
                                value: 'GB',
                                child: Text('United Kingdom (GB)'),
                              ),
                              PopupMenuItem(
                                value: 'JP',
                                child: Text('Japan (JP)'),
                              ),
                              PopupMenuItem(
                                value: 'SG',
                                child: Text('Singapore (SG)'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _languageCtrl.text.isEmpty ? 'zh-CN' : _languageCtrl.text,
                        decoration: InputDecoration(
                          labelText: l10n.language,
                          prefixIcon: const Icon(Icons.language),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'zh-CN',
                            child: Text('中文'),
                          ),
                          DropdownMenuItem(
                            value: 'en-US',
                            child: Text('English'),
                          ),
                        ],
                        onChanged: (val) async {
                          if (val != null) {
                            _languageCtrl.text = val;
                            final loc = val == 'zh-CN'
                                ? const Locale('zh', 'CN')
                                : const Locale('en', 'US');
                            ref.read(localeOverrideProvider.notifier).state = loc;
                            await config_api.setLanguage(language: val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nicknameCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.nickname,
                          prefixIcon: const Icon(Icons.person),
                          suffixIcon: IconButton(
                            tooltip: 'random nickname',
                            icon: const Icon(Icons.shuffle),
                            onPressed: () => _pickNicknameByGender(_genderKey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('N/A'),
                          selected: _genderKey == null,
                          onSelected: (_) {
                            setState(() {
                              _genderKey = null;
                              _genderValue = 0;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('♂'),
                          selected: _genderKey == 'male',
                          onSelected: (_) {
                            setState(() {
                              _genderKey = 'male';
                              _genderValue = 1;
                            });
                            _pickNicknameByGender(_genderKey);
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('♀'),
                          selected: _genderKey == 'female',
                          onSelected: (_) {
                            setState(() {
                              _genderKey = 'female';
                              _genderValue = 2;
                            });
                            _pickNicknameByGender(_genderKey);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.verificationCode,
                          prefixIcon: const Icon(Icons.verified_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: _sendingCode || _countdown > 0
                          ? null
                          : _sendCode,
                      child: _sendingCode
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _countdown > 0 ? l10n.resendIn(_countdown) : l10n.sendCode,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _verifying ? null : _verifyCode,
                  child: _verifying
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.submit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
