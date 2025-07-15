import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lowkey/auth/auth_bloc.dart';
import 'package:lowkey/home_page.dart';
import 'package:lowkey/auth/signup_page.dart'; // Assuming you have a HomePage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Lowkey Login'),
      ),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(builder: (_) => const HomePage()),
            );
          } else if (state is AuthError) {
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Login Error'),
                content: Text(state.message),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoTextField(
                    controller: _emailController,
                    placeholder: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.systemGrey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  CupertinoTextField(
                    controller: _passwordController,
                    placeholder: 'Password',
                    obscureText: true,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.systemGrey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  if (state is AuthLoading)
                    const CupertinoActivityIndicator()
                  else
                    CupertinoButton.filled(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              AuthLoginRequested(
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );
                      },
                      child: const Text('Login'),
                    ),
                  const SizedBox(height: 16.0),
                  CupertinoButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthBiometricLoginRequested());
                    },
                    child: const Text('Login with Biometrics'),
                  ),
                  const SizedBox(height: 16.0),
                  CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}