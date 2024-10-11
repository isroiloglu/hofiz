import 'dart:developer';

import 'package:arabic_tools/arabic_tools.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:hofiz/core/bloc/page/page_bloc.dart';
import 'package:hofiz/core/const/colors.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechPage extends StatefulWidget {
  const SpeechPage({Key? key}) : super(key: key);

  @override
  State<SpeechPage> createState() => _SpeechPageState();
}

class _SpeechPageState extends State<SpeechPage> {
  stt.SpeechToText? _speechToText;
  List<List<String>> words = [];
  bool _isListening = false;
  String _textQuran = '';
  String _text = 'Press button and speak';
  PageBloc bloc = PageBloc();
  double _confidence = 1.0;
  final Map<String, HighlightedWord> _highlights = {
    'quran': HighlightedWord(
      onTap: () {
        log('QURAN');
      },
      textStyle:
          const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
    ),
    'ربِ': HighlightedWord(
      onTap: () {
        log('ESCOBAR');
      },
      textStyle:
          const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
    )
  };

  @override
  void initState() {
    _speechToText = stt.SpeechToText();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocBuilder<PageBloc, PageState>(
        builder: (context, state) {
          if (state is PageInitial) {
            bloc.add(LoadPage(page: 1));
          }
          if (state is LoadedPage) {
            for (var value in state.page.data.ayahs) {
              if (value.text.contains('\n')) {
                value.text.replaceAll(RegExp(r"\\n"), "");
              }
              // if (value.numberInSurah == 1) {
              //   _textQuran = '${value.text}۝';
              // } else {
              //   _textQuran = '$_textQuran${value.text}۝';
              // }
            }
            for (var element in state.page.data.ayahs) {
              words.add(element.text.trim().split(' '));
            }

            return Scaffold(
                appBar: AppBar(
                  title: Text(
                      'Confidence ${(_confidence * 100).toStringAsFixed(1)}%'),
                  backgroundColor: Colors.green.shade400,
                ),
                body: Column(
                  children: [
                    Container(
                      color: AppColors.green.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: Wrap(
                        textDirection: TextDirection.rtl,
                        alignment: WrapAlignment.center,
                        children: words
                            .map((e) => Wrap(
                                textDirection: TextDirection.rtl,
                                alignment: WrapAlignment.center,
                                children: e.map((t) {
                                  // log('WORD ISH $t KEY IS${e.surah}+${e.numberInSurah}+${e.text.trim().split(' ').indexOf(t)}');
                                  return Text(t,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'NotoNaskhArabic',
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ));
                                }).toList()))
                            .toList(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(30, 30, 30, 150),
                      child: TextHighlight(
                        text: _text,
                        words: _highlights,
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'NotoNaskhArabic',
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: AvatarGlow(
                  animate: _isListening,
                  glowShape: BoxShape.circle,
                  duration: const Duration(milliseconds: 1500),
                  repeat: true,
                  glowColor: Theme.of(context).primaryColor,
                  child: FloatingActionButton(
                    onPressed: () {
                      // String a = state.page.data.ayahs[0].text.replaceAllMapped(
                      //     RegExp(word.split("").join("\\p{M}*"),
                      //         caseSensitive: false, unicode: true),
                      //     (Match m) => "<span>${m[0]}</span>");
                      _listen(state.page.data.ayahs[0].text.trim().split(' '));
                    },
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                    ),
                  ),
                ));
          }
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
    );
  }

  void _listen(List<String> ayah_words) async {
    if (!_isListening) {
      bool available = await _speechToText!.initialize(
        onStatus: (val) => log('onStatus $val'),
        onError: (val) => log('onError $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speechToText!.listen(
            onResult: (val) {
              List<String> words = val.recognizedWords.trim().split(' ');
              // List<String> ayah_words = ayah.text.trim().split(' ');
              if (val.recognizedWords.isNotEmpty) {
                // log('LAST IS ${words.last}');
                for (int i = 0; i < ayah_words.length; i++) {
                  if (ayah_words[i] == words.last) {
                    log('-----${ayah_words[i]}EQUAL TO${words.last}');
                  } else {
                    log('-----${ayah_words[i]}NOT EQUAL TO${words.last}');
                  }
                }
              }
              log('LAST IS ${words.toSet()}');

              setState(() {
                _text = val.recognizedWords.toLowerCase();
                if (val.hasConfidenceRating && val.confidence > 0) {
                  _confidence = val.confidence;
                }
              });
            },
            listenOptions: stt.SpeechListenOptions(),
            localeId: 'ar-IL'
            // localeId: 'ar-DZ'
            );
      }
    } else {
      setState(() {
        _isListening = false;
        _speechToText!.stop();
      });
    }
  }
}
