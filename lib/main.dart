// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:statsig/statsig.dart';

void main() async {
  final user = StatsigUser(userId: "a-user");
  final options = StatsigOptions(initTimeout: 1);
  await Statsig.initialize("client-{SDK_KEY_HERE}", user, options);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Startup Name Generator'),
        ),
        body: const Center(
          child: RandomWords(),
        ),
      ),
    );
  }
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _emojis = <String>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  final _massiveFont = const TextStyle(fontSize: 32);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return const Divider();

        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }

        Text? trailing;
        var emoji = "";
        var experiment = Statsig.getExperiment("emoji_logos");
        if (experiment.get("emojis_enabled", false) == true) {
          while (_emojis.length <= i) {
            const minHex = 0x1F300;
            const maxHex = 0x1F3F0;
            var random = (Random().nextInt((maxHex - minHex).abs() + 1) +
                    min(minHex, maxHex))
                .toInt();

            _emojis.add(String.fromCharCode(random));
          }

          emoji = _emojis[i];

          trailing = Text(
            emoji,
            style: _massiveFont,
          );
        }

        final name = _suggestions[index].asPascalCase;

        return ListTile(
          onTap: () {
            Statsig.logEvent("selected_name", stringValue: name);

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  name,
                  style: _biggerFont,
                ),
              ),
            );
          },
          title: Text(
            name,
            style: _biggerFont,
          ),
          trailing: trailing,
        );
      },
    );
  }

  Future<void> loadStatsig() async {}
}

class RandomWords extends StatefulWidget {
  const RandomWords({super.key});

  @override
  State<RandomWords> createState() => _RandomWordsState();
}
