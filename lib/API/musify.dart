import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:musify/helper/formatter.dart';
import 'package:musify/helper/mediaitem.dart';
import 'package:musify/services/audio_handler.dart';
import 'package:musify/services/audio_manager.dart';
import 'package:musify/services/data_manager.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final yt = YoutubeExplode();
final OnAudioQuery _audioQuery = OnAudioQuery();

List ytplaylists = [];

List searchedList = [];
List playlists = [];
List userPlaylists = [];
List userLikedSongsList = [];
List suggestedPlaylists = [];
List<SongModel> localSongs = [];

final lyrics = ValueNotifier<String>("null");
String _lastLyricsUrl = "";

dynamic activeSong;

int? id = 0;

List activePlaylist = [];

Future<List> fetchSongsList(String searchQuery) async {
  final List list = await yt.search.search(searchQuery);
  searchedList = [];
  for (var s in list) {
    searchedList.add(
      returnSongLayout(
        0,
        s.id.toString(),
        formatSongTitle(s.title.split('-')[s.title.split('-').length - 1]),
        s.thumbnails.standardResUrl,
        s.thumbnails.lowResUrl,
        s.thumbnails.maxResUrl,
        s.title.split('-')[0],
      ),
    );
  }
  return searchedList;
}

Future get10Music(playlistId) async {
  var newSongs = [];
  var index = 0;
  await for (var song in yt.playlists.getVideos(playlistId).take(10)) {
    newSongs.add(
      returnSongLayout(
        index,
        song.id.toString(),
        formatSongTitle(
          song.title.split('-')[song.title.split('-').length - 1],
        ),
        song.thumbnails.standardResUrl,
        song.thumbnails.lowResUrl,
        song.thumbnails.maxResUrl,
        song.title.split('-')[0],
      ),
    );
    index += 1;
  }

  return newSongs;
}

Future<List<dynamic>> getUserPlaylists() async {
  var playlistsByUser = [];
  for (final playlistID in userPlaylists) {
    final plist = await yt.playlists.get(playlistID);
    playlistsByUser.add({
      "ytid": plist.id,
      "title": plist.title,
      "subtitle": "Just Updated",
      "header_desc": plist.description.length < 120
          ? plist.description
          : plist.description.substring(0, 120),
      "type": "playlist",
      "image": "",
      "list": []
    });
  }
  return playlistsByUser;
}

