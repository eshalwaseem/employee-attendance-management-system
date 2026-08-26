import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart'; 
import 'app.dart';

import 'authentication/bloc/auth_bloc.dart';
import 'authentication/bloc/auth_event.dart';
import 'authentication/repository/firebase_auth_repository.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final authRepository = FirebaseAuthRepository();

  runApp(
    RepositoryProvider<FirebaseAuthRepository>.value(
      value: authRepository,
      child: BlocProvider<AuthBloc>(
        create: (_) =>
            AuthBloc(repository: authRepository)
              ..add(const AuthSessionRequested()),
        child: const App(),
      ),
    ),
  );
}
 