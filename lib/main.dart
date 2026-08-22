import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'authentication/bloc/auth_bloc.dart';
import 'simple_bloc_observer.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();

  runApp(BlocProvider<AuthBloc>(create: (_) => AuthBloc(), child: const App()));
}
