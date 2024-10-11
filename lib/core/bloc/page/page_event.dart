part of 'page_bloc.dart';

@immutable
abstract class PageEvent extends Equatable {}

class LoadPage extends PageEvent {
  final int page;

  LoadPage({required this.page});

  @override
  List<Object?> get props => [page];
}
