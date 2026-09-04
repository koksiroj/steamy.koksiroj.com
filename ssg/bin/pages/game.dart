import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
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
  final name = p.basename(dirGame.path);
  if (name.contains(RegExp(r"\s"))) {
    throw Exception("Folder `${dirGame.path}` contains whitespace, which is not allowed in URLs!");
  }
  final dirBuildGame = Directory(p.join(dirBuild.path, language.code, name))..createSync();
  final fileCapsuleSmall = File(p.join(dirGame.path, "store_capsule_small.jpg"));
  await fileCapsuleSmall.copy(p.join(dirBuildGame.path, p.basename(fileCapsuleSmall.path)));
  if (File(p.join(dirGame.path, "link.txt")).existsSync()) return;

  final fileTitle = File(p.join(dirGame.path, "title.txt"));
  final title = fileTitle.readAsStringSync().trim();
  final fileDescription = File(p.join(dirGame.path, "description.txt"));
  final description = fileDescription.readAsStringSync().trim();
  final translations = Translations(File(p.join(language.directory.path, "translations.yaml")));

  final String indexHTML = HTML(
    lang: language.code,
    head: generateHead(
      title: "$title | Steamy",
      description: description,
      extraStyles: ["header", "game"],
      scriptFiles: ["/lang-select.js"],
    ),
    body: await _generateBody(dirGame, dirBuildGame, language, translations),
  ).build();
  File(p.join(dirBuildGame.path, "index.html")).writeAsStringSync(indexHTML);
}

Future<Body> _generateBody(
  Directory dirGame,
  Directory dirBuildGame,
  Language language,
  Translations translations,
) async {
  final List<A> otherLanguages = [];
  for (final Language language in languages) {
    final Directory dirOtherGame = Directory(
      p.join(language.directory.path, p.basename(dirGame.path)),
    );
    if (dirOtherGame.existsSync()) {
      otherLanguages.add(
        A.text(language.display, href: "/${language.code}/${p.basename(dirGame.path)}"),
      );
    }
  }

  return Body(
    header: generateHeader(language, translations, languageLinks: otherLanguages),
    main: await _generateMain(dirGame, dirBuildGame, translations),
    footer: Footer(children: []),
  );
}

Future<Main> _generateMain(
  Directory dirGame,
  Directory dirBuildGame,
  Translations translations,
) async {
  final fileTitle = File(p.join(dirGame.path, "title.txt"));
  final title = fileTitle.readAsStringSync().trim();

  final fileDescription = File(p.join(dirGame.path, "description.txt"));
  final description = fileDescription.readAsStringSync().trim();

  final fileReleaseDate = File(p.join(dirGame.path, "release_date.txt"));
  final String releaseDate = fileReleaseDate.readAsStringSync().trim();

  final fileTags = File(p.join(dirGame.path, "tags.txt"));
  final tags = fileTags.readAsStringSync().trim().split(",").map((e) => e.trim());

  final fileBreadcrumb = File(p.join(dirGame.path, "breadcrumb.txt"));
  final breadcrumb = fileBreadcrumb.readAsStringSync().trim();

  final List<Element> elements = [];

  elements.add(
    Div(
      classes: ["top-area"],
      children: [
        Div(
          classes: ["game-page_background"],
          children: [
            Image(classes: ["game-colour"], src: "store_page_background.jpg", alt: ""),
            Image(classes: ["game-texture"], src: "store_page_background.jpg", alt: ""),
          ],
        ),
        Div(
          classes: ["title-area", "page-content"],
          children: [
            Div(
              classes: ["breadcrumbs"],
              children: [
                Span.text(translations["breadcrumb-all-games"]),
                T(">"),
                Span.text(breadcrumb),
                T(">"),
                Span.text(title),
              ],
            ),
            H1.text(title),
          ],
        ),
        Div(
          classes: ["game-background-glow"],
          children: [
            Div(
              classes: ["game-highlights", "page-content"],
              children: [
                Div(
                  classes: ["right-column"],
                  children: [
                    Image(src: "store_capsule_header.jpg", alt: ""),
                    P.text(description),
                    Div(
                      classes: ["detail"],
                      children: [
                        Span.text("${translations["release-date"]}:", classes: ["detail-key"]),
                        Span.text(releaseDate, classes: ["detail-value"]),
                      ],
                    ),
                    Span.text("${translations["tags"]}:", classes: ["detail-key"]),
                    UnorderedList(items: tags.map(ListItem.text), classes: ["tags"]),
                  ],
                ),
                Div(
                  classes: ["left-column"],
                  children: [],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  final filePrice = File(p.join(dirGame.path, "price.txt"));
  Div? buyArea;
  if (filePrice.existsSync()) {
    final String price = filePrice.readAsStringSync().trim();
    buyArea = Div(
      classes: ["buy-area"],
      children: [
        H2.text(translations["buy-area"].replaceAll("{game}", title)),
        Div(
          classes: ["buy-action"],
          children: [
            Span.text(price, classes: ["buy-price"]),
            Span.text(translations["buy-add-to-cart"], classes: ["btn_green_steamui"]),
          ],
        ),
      ],
    );
  }

  final fileAbout = File(p.join(dirGame.path, "about.md"));
  final about = fileAbout.readAsStringSync();
  final mdAbout = markdown(about);

  elements.add(
    Div(
      classes: ["middle-page", "page-content"],
      children: [
        Div(
          classes: ["right-column", "game-metadata"],
          children: [],
        ),
        Div(
          classes: ["left-column", "game-description-column"],
          children: [
            Div(
              classes: ["coming-area"],
              children: [
                Div(
                  classes: ["coming-content"],
                  children: [
                    Span.text(translations["this-game-is-not-available"], classes: ["not-yet"]),
                    H2.text(translations["coming"]),
                  ],
                ),
                Div(
                  classes: ["coming-wishlist"],
                  children: [
                    Span(
                      classes: ["wishlist-note"],
                      children: [
                        T(translations["wishlist-note-line1"]),
                        Br(),
                        T(translations["wishlist-note-line2"]),
                      ],
                    ),
                    Span.text(translations["wishlist-button"], classes: ["btn_green_steamui"]),
                  ],
                ),
              ],
            ),
            ?buyArea,
            Div(
              classes: ["about"],
              children: [
                H2.text(translations["about-game"]),
                ...mdAbout,
              ],
            ),
          ],
        ),
      ],
    ),
  );

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
