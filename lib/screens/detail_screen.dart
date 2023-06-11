import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toonflix/services/api_service.dart';

import '../models/webtoon_detail_model.dart';
import '../models/webtoon_episode_model.dart';
import '../widgets/episode_widget.dart';

class DetailScreen extends StatefulWidget {
  final title, thumb, id;

  const DetailScreen({super.key, this.title, this.thumb, this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;
  late SharedPreferences pref;
  bool isLiked = false;

  Future initPref() async {
    pref = await SharedPreferences.getInstance();
    final likedToons = pref.getStringList('likedToons');
    if (likedToons != null) {
      if (likedToons.contains(widget.id) == true) {
        setState(() {
          isLiked = true;
        });
      }
    } else {
      await pref.setStringList('likedToons', []);
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLatestEpisodeById(widget.id);
    initPref();
  }

  onHeartTap() async {
    final likedToons = pref.getStringList('likedToons');
    if (likedToons != null) {
      if (isLiked) {
        likedToons.remove(widget.id);
      } else {
        likedToons.add(widget.id);
      }
      await pref.setStringList('likedToons', likedToons);
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: onHeartTap,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_outline_outlined,
                ))
          ],
          centerTitle: true,
          elevation: 1,
          title: Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          foregroundColor: Colors.green,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: widget.id,
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        width: 180,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 7,
                                offset: const Offset(7, 7),
                                color: Colors.black.withOpacity(0.5),
                              )
                            ]),
                        child: Image.network(
                          widget.thumb,
                          headers: const {
                            "User-Agent":
                                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data!.about,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${snapshot.data!.genre} / ${snapshot.data!.age}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      );
                    }
                    return const Text("...");
                  },
                  future: webtoon,
                ),
                const SizedBox(height: 10),
                FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          for (var episode in snapshot.data!.sublist(0, 10))
                            Episode(episode: episode, webtoonID: widget.id)
                        ],
                      );
                    }
                    return Container();
                  },
                  future: episodes,
                )
              ],
            ),
          ),
        ));
  }
}
