import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../theme/tokens.dart';

/// Signing in with the same login as hub.clayaiken.com.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key, this.message});
  final String? message;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false;
  bool _show = false;
  String? _error;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    if (_user.text.trim().isEmpty || _pass.text.isEmpty) {
      setState(() => _error = 'Enter your hub username or email, and your password.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await ref.read(syncServiceProvider).signIn(_user.text, _pass.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'K',
                        style: TextStyle(color: c.onPrimary, fontSize: 30, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Sign in to Kolumn', textAlign: TextAlign.center, style: t.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Use the same login as hub.clayaiken.com.',
                    textAlign: TextAlign.center,
                    style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant),
                  ),
                  if (widget.message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.message!,
                      textAlign: TextAlign.center,
                      style: t.bodyMedium!.copyWith(color: c.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextField(
                    controller: _user,
                    autofillHints: const [AutofillHints.username],
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Username or email'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pass,
                    obscureText: !_show,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _go(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        tooltip: _show ? 'Hide password' : 'Show password',
                        onPressed: () => setState(() => _show = !_show),
                        icon: Icon(_show ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                      ),
                    ),
                  ),
                  if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: t.bodyMedium!.copyWith(color: c.error))],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _go,
                    child: _busy
                        ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: c.onPrimary))
                        : const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
