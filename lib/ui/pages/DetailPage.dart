import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/ui/pages/CommentsPage.dart';
import 'package:flutter_yyets/ui/widgets/EpisodeWidget.dart';
import 'package:flutter_yyets/ui/widgets/MovieResWidget.dart';
import 'package:flutter_yyets/ui/widgets/MoviesGridWidget.dart';

class DetailPage extends StatefulWidget {
  final dynamic data;

  DetailPage(this.data);

  @override
  State createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  get data => widget.data;
  Map<String, dynamic> detail;

  Map<String, dynamic> get resource => detail != null ? detail["resource"] : {};

  bool _hasErr = false;

  String get title => () {
        var enname = data['enname'];
        return data["cnname"] + (enname == null ? "" : "($enname)");
      }();

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    loadData();
  }

  void loadData() {
    Api.getDetail(data["id"]).then((d) {
      if (mounted) {
        setState(() {
          detail = d;
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _hasErr = true;
        });
      }
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.black,
                  pinned: true,
                  floating: true,
                  automaticallyImplyLeading: false,
                  expandedHeight: 282,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Container(
                      //头部整个背景颜色
                      height: double.infinity,
                      child: _buildDetail(),
                    ),
                  ),
                  bottom: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: [
                        Tab(text: "剧集"),
                        Tab(text: "介绍"),
                        Tab(
                            text: "评论" +
                                (detail == null
                                    ? ""
                                    : "(${detail['comments_count']})")),
                        Tab(text: "推荐"),
                      ]),
                ),
              ];
            },
            body: _hasErr
                ? Center(
                    child: FlatButton(
                      child: Text("获取失败，点击重试"),
                      onPressed: () {
                        loadData();
                      },
                    ),
                  )
                : detail == null
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: <Widget>[
                          detail["season_list"] == null
                              ? MovieResWidget(detail['movie_items'], resource)
                              : EpisodeWidget(detail["season_list"], resource),
                          SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(resource['content'] ?? ""),
                            ),
                          ),
                          CommentsPage(
                            data['id'],
                            detail["comments_hot"],
                            resource['channel']
                          ),
                          MoviesGridWidget(detail['similar']),
                        ],
                      )));
  }

  Widget _buildDetail() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Hero(
          child: Image.network(
            data["poster"],
            fit: BoxFit.cover,
            width: 150,
            height: 280.0 - 46,
          ),
          tag: "img_${data["id"]}"),
      Expanded(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 2,
                    style: TextStyle(fontSize: 18),
                    overflow: TextOverflow.fade,
                  ),
                  Container(
                    height: 10,
                  ),
                  Text(data["play_status"] ?? resource["play_status"] ?? ""),
                ],
              ),
            ),
//            Positioned(
//              bottom: 46,
//              child: Padding(
//                padding: EdgeInsets.all(10),
//                child: GridView.count(
//                  shrinkWrap: true,
//                  childAspectRatio: 1,
//                  children: <Widget>[
//                    Text("No.11111111111"),
////                    Text("No." + (detail == null ? ".." : detail["rank"])),
////                    Text("No." + (detail == null ? ".." : detail["rank"])),
//                  ],
//                  crossAxisCount: 3,
//                ),
//              ),
//            )
          ],
        ),
      ),
    ]);
  }
}