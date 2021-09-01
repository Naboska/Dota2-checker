import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../utils/dota_directory.dart';
import '../../constants/theme.dart';
import 'models/last_game.dart';
import 'widgets/game_side_widget/game_side_widget.dart';

class GameScreen extends StatefulWidget {
  final dotaDirectory = DotaDirectory();

  GameScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? gameCheckTimer;
  LastGame? lastGame;

  Future<void> _read() async {
    String? dotaDir = await widget.dotaDirectory.getDotaDirectory();
    File file = File('$dotaDir/game/dota/server_log.txt');
    String serverConfig = await file.readAsString();
    LastGame newGame = LastGame.fromServerConfig(serverConfig: serverConfig);

    if (newGame.gameTime != lastGame?.gameTime) {
      setState(() => lastGame = newGame);
    }
  }

  @override
  void initState() {
    _read();

    gameCheckTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) => _read());

    super.initState();
  }

  @override
  void dispose() {
    gameCheckTimer!.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isGameTurbo = lastGame?.isTurbo ?? true;
    final bool isRadiantNotEmpty =
        lastGame?.radiant != null && lastGame!.radiant.isNotEmpty;
    final bool isDireNotEmpty =
        lastGame?.dire != null && lastGame!.dire.isNotEmpty;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Dota 2 Checker'),
        ),
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        Text('Лобби${isGameTurbo ? '(Turbo)' : ''}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15)),
                        Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(' ${lastGame?.lobby ?? 'не найдено'}')),
                        Text(lastGame?.gameTime != null
                            ? '(${lastGame!.gameTime})'
                            : '')
                      ])),
                  isRadiantNotEmpty
                      ? GameSideWidget(
                          side: 'The Radiant',
                          sideColor: radiantColor,
                          players: lastGame?.radiant,
                          isTurbo: isGameTurbo,
                        )
                      : Container(),
                  isDireNotEmpty
                      ? GameSideWidget(
                          side: 'The Dire',
                          sideColor: direColor,
                          players: lastGame?.dire,
                          isTurbo: isGameTurbo,
                        )
                      : Container(),
                ]))));
  }
}
