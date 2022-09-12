import 'package:flutter/material.dart';
import 'package:pinboard_clone/models/post/post.dart';
import 'package:pinboard_clone/services/local_services/tag.data.services.dart';
import 'package:stacked/stacked.dart';

import '../../../app/locator.dart';
import '../../../models/tag/tag.dart';
import '../../../services/local_services/post.services.dart';

class PinsScreenViewModel extends ReactiveViewModel {
  final _firstPinFocusNode = FocusNode();
  // pull in services via locator
  final _postService = locator<PostService>();
  final _tagService = locator<TagService>();
  // pull in service methods view ViewModel
  late final removePin = _postService.removePost;
  late final updatePinContent = _postService.updatePinDataContent;
  late final getTagByName = _tagService.getTagByName;

  // getters for pin and tag
  List<Post> get posts => _postService.posts;

  List<Tag> get tags => _tagService.tags;

  Tag get currentTag => _tagService.currentTag;

  void newPin() {
    _postService.newPost();
    _firstPinFocusNode.requestFocus();
  }

  FocusNode? getFocusNode(String id) {
    final index = posts.indexWhere((post) => post.id == id);
    return index == 0 ? _firstPinFocusNode : null;
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices =>
      [_postService, _tagService];
}