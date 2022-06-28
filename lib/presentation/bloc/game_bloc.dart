/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to
/// deal in the Software without restriction, including without limitation the
/// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
/// sell copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge,
/// publish, distribute, sublicense, create a derivative work, and/or sell
/// copies of the Software in any work that is designed, intended, or marketed
/// for pedagogical or instructional purposes related to programming, coding,
/// application development, or information technology.  Permission for such
/// use, copying, modification, merger, publication, distribution, sublicensing,
///  creation of derivative works, or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
/// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
///  IN THE SOFTWARE.
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import '../../data.dart';
import '../../domain.dart';

part 'game_event.dart';
part 'game_state.dart';

/// Handles all logic related to the game.
class GameBloc extends Bloc<GameEvent, GameState> {
  /// Constructor
  GameBloc(this._statsRepository)
      : super(GameState(
          guesses: emptyGuesses(),
        )) {
    on<GameStarted>(_onGameStarted);
    // on<LetterKeyPressed>(_onLetterKeyPressed);
    on<LetterKeyPressed>(_onLetterKeyPressed, transformer: sequential());
    on<GameFinished>(_onGameFinished);
  }

  /// Interacts with storage for updating game stats.
  final GameStatsRepository _statsRepository;

  // TODO: Add logic for GameStarted
  void _onGameStarted(
    GameStarted event,
    Emitter<GameState> emit,
  ) {
    print('Game has started!');
    final puzzle = nextPuzzle(puzzles);
    final guesses = emptyGuesses();
    emit(GameState(
      guesses: guesses,
      puzzle: puzzle,
    ));
  }

  // TODO: Add logic for GameFinished
  // 1
  Future<void> _onGameFinished(
    GameFinished event,
    Emitter<GameState> emit,
  ) async {
    // 2
    await _statsRepository.addGameFinished(hasWon: event.hasWon);
    // 3
    emit(state.copyWith(
      status: event.hasWon ? GameStatus.success : GameStatus.failure,
    ));
  }

  // TODO: Add logic for LetterKeyPressed
  Future<void> _onLetterKeyPressed(
    LetterKeyPressed event,
    Emitter<GameState> emit,
  ) async {
    final puzzle = state.puzzle;
    final guesses = addLetterToGuesses(state.guesses, event.letter);

    // 1
    emit(state.copyWith(
      guesses: guesses,
    ));

    // 2
    final words = guesses
        .map((guess) => guess.join())
        .where((word) => word.isNotEmpty)
        .toList();

    final hasWon = words.contains(puzzle);
    final hasMaxAttempts = words.length == kMaxGuesses &&
        words.every((word) => word.length == kWordLength);
    if (hasWon || hasMaxAttempts) {
      add(GameFinished(hasWon: hasWon));
    }
  }
}
