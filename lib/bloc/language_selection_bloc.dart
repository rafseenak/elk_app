import 'package:elk/bloc/event/language_screen_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageSelectionBloc extends Bloc<LanguageSelectionEvent, String> {
  LanguageSelectionBloc() : super('') {
    on<LanguageSelectionEvent>((event, emit) => emit(event.language));
  }
}
