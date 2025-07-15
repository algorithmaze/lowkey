
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:lowkey/auth/auth_bloc.dart';
import 'package:lowkey/auth/login_page.dart';
import 'package:lowkey/calls/call_service.dart';
import 'package:lowkey/core/app_colors.dart';
import 'package:lowkey/core/app_lock_screen.dart';
import 'package:lowkey/core/app_lock_service.dart';
import 'package:lowkey/core/encryption_service.dart';
import 'package:lowkey/core/file_service.dart';
import 'package:lowkey/core/key_service.dart';
import 'package:lowkey/home_page.dart';
import 'package:lowkey/contacts/friend_service.dart';
import 'package:lowkey/contacts/friends_bloc.dart';
import 'package:lowkey/contacts/user_repository.dart';
import 'package:lowkey/chat/chat_repository.dart';

final EncryptionService encryptionService = EncryptionService();
late final KeyService keyService;
late final AppLockService appLockService;
late final CallService callService;
late final FileService fileService;
late final ChatRepository chatRepository;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://thajkwsueiyighhrelii.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRoYWprd3N1ZWl5aWdoaHJlbGlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1NTQ1MjEsImV4cCI6MjA2ODEzMDUyMX0.7AEnwaoiOlvN8YPVzxvSskWkUS3eeHUHWuebG-Tpu8E', // Replace with your Supabase Anon Key
  );

  await encryptionService.init();
  keyService = KeyService(const FlutterSecureStorage(), Supabase.instance.client);
  appLockService = AppLockService(const FlutterSecureStorage());
  callService = CallService(Supabase.instance.client);
  await callService.initRenderers();
  fileService = FileService(Supabase.instance.client);
  chatRepository = ChatRepository(Supabase.instance.client, fileService);

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appLockService.startInactivityTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      appLockService.startInactivityTimer();
    } else if (state == AppLifecycleState.resumed) {
      appLockService.userActivityDetected();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            supabaseClient: Supabase.instance.client,
            localAuth: LocalAuthentication(),
            userRepository: UserRepository(Supabase.instance.client),
          )..add(AuthCheckStatus()),
        ),
        BlocProvider(
          create: (context) => FriendsBloc(
            friendService: FriendService(Supabase.instance.client, chatRepository),
            chatRepository: chatRepository,
          ),
        ),
        ChangeNotifierProvider.value(value: appLockService),
        Provider.value(value: callService),
        Provider.value(value: fileService),
      ],
      child: GestureDetector(
        onTap: appLockService.userActivityDetected,
        onPanDown: (_) => appLockService.userActivityDetected(),
        onScaleStart: (_) => appLockService.userActivityDetected(),
        child: Consumer<AppLockService>(
          builder: (context, appLockService, child) {
            if (appLockService.isLocked) {
              return const AppLockScreen();
            }
            return CupertinoApp(
              title: 'Lowkey',
              theme: const CupertinoThemeData(
                primaryColor: AppColors.primaryBlue,
              ),
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return const HomePage();
                  } else if (state is AuthUnauthenticated) {
                    return const LoginPage();
                  }
                  return const CupertinoActivityIndicator(); // Or a splash screen
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
