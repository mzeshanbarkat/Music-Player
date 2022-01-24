import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'music_list.dart';

class MusicApp extends StatefulWidget {
  const MusicApp({Key? key}) : super(key: key);

  @override
  _MusicAppState createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  final GlobalKey<_MusicAppState> key = GlobalKey<_MusicAppState>();

  String currentTitle = "";
  String currentArtist = "";
  String currentCover = "";
  String currentSong = "";
  IconData btnIcon = Icons.play_arrow;
  double currentValue = 0.0;
  int currentIndex = 0;
  Color color = Colors.white;
  List<IconData> _icons = [Icons.repeat, Icons.repeat_on];

  AudioPlayer _audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  bool isPlaying = false;
  bool isRepeat = false;
  Duration musicDuration = Duration();
  Duration musicPosition = Duration();

  playMusic(String url) async {
    if (isPlaying && currentSong != url) {
      _audioPlayer.pause();
      int result = await _audioPlayer.play(url);
      if (result == 1) {
        setState(() {
          currentSong = url;
        });
      }
    } else if (!isPlaying) {
      int result = await _audioPlayer.play(url);
      if (result == 1) {
        setState(() {
          isPlaying = true;
          btnIcon = Icons.pause;
        });
      }
    }

    _audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        musicDuration = event;
      });
    });

    _audioPlayer.onAudioPositionChanged.listen((event) {
      setState(() {
        musicPosition = event;
      });
    });

    _audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        musicPosition = Duration(seconds: 0);
        if (isPlaying) {
          _audioPlayer.pause();
          btnIcon = Icons.play_arrow;
          isPlaying = false;
        }
      });
    });
  }

  void changeTrack(bool isNext) {
    if (isNext) {
      if (currentIndex != currentSong.length + 1) {
        currentIndex++;
      }
    } else {
      if (currentIndex != 0) {
        currentIndex--;
      }
    }

    key.currentState!.playMusic(currentSong[currentIndex]);
  }

  @override
  void onSkipToNext() {
    if (currentIndex < musicList.length - 1)
      currentIndex = currentIndex + 1;
    else
      currentIndex = 0;
    playMusic(musicList[currentIndex]["url"]);

    setState(() {
      currentTitle = musicList[currentIndex]["title"];
      currentSong = musicList[currentIndex]["surah"];
    });
    return onSkipToNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff3C415C),
              Color(0xff232323),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  left: 22.0,
                  right: 22.0,
                  top: 15.0,
                  bottom: 15.0,
                ),
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Music play",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 22.0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: musicList.length,
                    itemBuilder: (context, index) => InkWell(
                      onTap: () {
                        playMusic(musicList[index]["url"]);
                        setState(() {
                          currentTitle = musicList[index]["title"];
                          currentArtist = musicList[index]["artist"];
                          currentCover = musicList[index]["cover"];
                        });
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            musicList[index]["cover"],
                          ),
                        ),
                        title: Text(
                          musicList[index]["title"],
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          musicList[index]["artist"],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        trailing: Container(
                          margin: EdgeInsets.all(17.0),
                          child: Icon(
                            Icons.music_note,
                            color: Colors.blueGrey.shade200,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      height: 1.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 22.0,
                        right: 30.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "${musicPosition.inMinutes}:${musicPosition.inSeconds.remainder(60)}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          Expanded(
                            child: Slider.adaptive(
                              activeColor: Colors.white,
                              inactiveColor: Colors.grey,
                              value: musicPosition.inSeconds.toDouble(),
                              min: 0.0,
                              max: musicDuration.inSeconds.toDouble(),
                              onChanged: (value) {
                                currentValue = value;
                                _audioPlayer.seek(
                                    Duration(seconds: currentValue.round()));
                              },
                            ),
                          ),
                          Text(
                            "${musicDuration.inMinutes}:${musicDuration.inSeconds.remainder(60)}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 22.0,
                        right: 30.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTitle,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                currentArtist,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: (Icon(
                              Icons.skip_previous,
                              color: Colors.white,
                            )),
                            onPressed: () {
                              changeTrack(false);
                            },
                          ),
                          IconButton(
                            icon: isRepeat == false
                                ? Icon(_icons[0])
                                : Icon(_icons[1]),
                            color: color,
                            onPressed: () {
                              setState(() {
                                if (isRepeat == false) {
                                  this
                                      ._audioPlayer
                                      .setReleaseMode(ReleaseMode.LOOP);
                                } else if (isRepeat == true) {
                                  this
                                      ._audioPlayer
                                      .setReleaseMode(ReleaseMode.RELEASE);
                                  color = Colors.blue;
                                } else {
                                  color = Colors.white;
                                }
                              });
                            },
                          ),
                          Container(
                            height: 40.0,
                            width: 40.0,
                            margin: EdgeInsets.all(7.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (isPlaying) {
                                  _audioPlayer.pause();
                                  setState(() {
                                    btnIcon = Icons.play_arrow;
                                    isPlaying = false;
                                  });
                                } else {
                                  _audioPlayer.resume();

                                  setState(() {
                                    btnIcon = Icons.pause;
                                    isPlaying = true;
                                  });
                                }
                              },
                              icon: Icon(
                                btnIcon,
                                size: 26,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.shuffle),
                            color: Colors.white,
                          ),
                          IconButton(
                            icon: (Icon(
                              Icons.skip_next,
                              color: Colors.white,
                            )),
                            onPressed: () {
                              changeTrack(true);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
