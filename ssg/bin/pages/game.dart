import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/head.dart";
import "package:ssg/constants.dart";
import "package:ssg/languages.dart";
import "package:techs_html_bindings/elements.dart";
import "package:techs_html_bindings/markdown.dart";
import "package:techs_html_bindings/utils.dart";

Future<void> createGamesPages() async {
  for (final Language language in languages) {
    final dirsGames = language.directory.listSync().whereType<Directory>();
    for (final Directory dirGame in dirsGames) {
      await _createGamePage(language, dirGame);
    }
  }
}

Future<void> _createGamePage(Language language, Directory dirGame) async {
  final fileTitle = File(p.join(dirGame.path, "title.txt"));
  final title = fileTitle.readAsStringSync().trim();
  final fileDescription = File(p.join(dirGame.path, "description.txt"));
  final description = fileDescription.readAsStringSync().trim();
  final name = p.basename(dirGame.path);
  if (name.contains(RegExp(r"\s"))) {
    throw Exception("Folder `${dirGame.path}` contains whitespace, which is not allowed in URLs!");
  }

  final dirBuildGame = Directory(p.join(dirBuild.path, language.code, name))..createSync();
  final String indexHTML = HTML(
    lang: language.code,
    head: generateHead(
      title: "$title | Steamy",
      description: description,
      extraStyles: ["game"],
    ),
    body: await _generateBody(dirGame, dirBuildGame),
  ).build();
  File(p.join(dirBuildGame.path, "index.html")).writeAsStringSync(indexHTML);
}

Future<Body> _generateBody(Directory dirGame, Directory dirBuildGame) async {
  return Body(
    header: Header(children: []),
    main: await _generateMain(dirGame, dirBuildGame),
    footer: Footer(children: []),
  );
}

Future<Main> _generateMain(Directory dirGame, Directory dirBuildGame) async {
  final List<Element> elements = [];

  final fileTitle = File(p.join(dirGame.path, "title.txt"));
  final title = fileTitle.readAsStringSync().trim();
  elements.add(H1.text(title));

  elements.add(Image(src: "header.jpg", alt: ""));

  final fileDescription = File(p.join(dirGame.path, "description.txt"));
  final description = fileDescription.readAsStringSync().trim();
  elements.add(P.text(description));

  final fileAbout = File(p.join(dirGame.path, "about.md"));
  final about = fileAbout.readAsStringSync();
  final mdAbout = markdown(about);
  elements.addAll(mdAbout);

  //Copy linked images
  final List<Image> images = [];
  elements.collectOfType(into: images);
  for (final Image img in images) {
    final uri = Uri.parse(img.src);
    if (uri.scheme.isNotEmpty) continue;
    final imgFile = File(p.join(dirGame.path, img.src));
    if (!imgFile.existsSync()) {
      throw Exception(
        "`${fileAbout.path}` links to image `${imgFile.path}` but that file does not exist!",
      );
    }
    final targetFile = File(p.join(dirBuildGame.path, img.src));
    await imgFile.copy(targetFile.path);
  }

  //Copy linked videos
  final List<Video> videos = [];
  elements.collectOfType(into: videos);
  for (final Video vid in videos) {
    final uri = Uri.parse(vid.src);
    if (uri.scheme.isNotEmpty) continue;
    final vidFile = File(p.join(dirGame.path, vid.src));
    if (!vidFile.existsSync()) {
      throw Exception(
        "`${fileAbout.path}` links to video `${vidFile.path}` but that file does not exist!",
      );
    }
    final targetFile = File(p.join(dirBuildGame.path, vid.src));
    await vidFile.copy(targetFile.path);
  }

  return Main(children: elements);
}
