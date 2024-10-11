part of 'page_bloc.dart';

@immutable
abstract class PageState extends Equatable {}

class PageInitial extends PageState {
  @override
  List<Object?> get props => [];
}

class LoadingPage extends PageState {
  @override
  List<Object?> get props => [];
}

class LoadedPage extends PageState {
  final PageModel page;

  LoadedPage({required this.page});

  @override
  List<Object?> get props => [];
}

class ErrorPage extends PageState {
  final String error;

  ErrorPage({required this.error});

  @override
  List<Object?> get props => [];
}
