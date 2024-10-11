import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hofiz/core/api/page_repository.dart';
import 'package:hofiz/core/models/page_model.dart';
import 'package:meta/meta.dart';

part 'page_event.dart';

part 'page_state.dart';

class PageBloc extends Bloc<PageEvent, PageState> {
  PageRepository repository = PageRepository();

  PageBloc() : super(PageInitial()) {
    on<PageEvent>((event, emit) async {
      if (event is LoadPage) {
        await _loadPage(event, emit);
      }
    });
  }

  Future<void> _loadPage(LoadPage event, Emitter<PageState> emit) async {
    try {
      emit(LoadingPage());
      var response = await repository.getPage(1);
      emit(LoadedPage(page: response));
    } catch (err) {
      log('ERROR IS ${err.toString()}');
      emit(ErrorPage(error: err.toString()));
    }
  }
}
