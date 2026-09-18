import "dart:collection";
import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/footer.dart";
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:ssg/constants.dart";
import "package:ssg/copy.dart";
import "package:ssg/key_value_file.dart";
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
  if (name.contains(RegExp(r"\W"))) {
    throw Exception(
      "Folder `${dirGame.path}` contains characters which are not allowed in URLs! Only `a-zA-Z0-9_` are allowed.",
    );
  }
  final dirBuildGame = Directory(p.join(dirBuild.path, language.code, name))..createSync();
  final fileCapsuleSmall = File(p.join(dirGame.path, "store_capsule_small.jpg"));
  await fileCapsuleSmall.copy(p.join(dirBuildGame.path, p.basename(fileCapsuleSmall.path)));
  if (File(p.join(dirGame.path, "link.txt")).existsSync()) return;

  final fileTitle = File(p.join(dirGame.path, "title.txt"));
  final title = fileTitle.readAsStringSync().trim();
  final fileDescription = File(p.join(dirGame.path, "description.txt"));
  final description = fileDescription.readAsStringSync().trim();
  final translations = KeyValueFile(File(p.join(language.directory.path, "translations.yaml")));

  final String indexHTML = HTML(
    lang: language.code,
    head: generateHead(
      title: "$title | Steamy",
      description: description,
      extraStyles: ["header", "game", "footer"],
      scriptFiles: ["/lang-select.js", "/carousel.js", "/sysreq.js"],
    ),
    body: await _generateBody(dirGame, dirBuildGame, language, translations),
  ).build();
  File(p.join(dirBuildGame.path, "index.html")).writeAsStringSync(indexHTML);
}

Future<Body> _generateBody(
  Directory dirGame,
  Directory dirBuildGame,
  Language language,
  KeyValueFile translations,
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
    footer: generateFooter(),
  );
}

Future<Main> _generateMain(
  Directory dirGame,
  Directory dirBuildGame,
  KeyValueFile translations,
) async {
  final fileTitle = File(p.join(dirGame.path, "title.txt"));
  final title = fileTitle.readAsStringSync().trim();

  final fileDescription = File(p.join(dirGame.path, "description.txt"));
  final description = fileDescription.readAsStringSync().trim();

  final fileReleaseDate = File(p.join(dirGame.path, "release_date.txt"));
  final String? releaseDate = fileReleaseDate.existsSync()
      ? fileReleaseDate.readAsStringSync().trim()
      : null;

  final fileTags = File(p.join(dirGame.path, "tags.txt"));
  final tags = fileTags.readAsStringSync().trim().split(",").map((e) => e.trim());

  final fileBreadcrumb = File(p.join(dirGame.path, "breadcrumb.txt"));
  final breadcrumb = fileBreadcrumb.readAsStringSync().trim();

  final sidebar = KeyValueFile(File(p.join(dirGame.path, "sidebar.yaml")));

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
                    _detail(
                      "${translations["release-date"]}:",
                      releaseDate ?? translations["coming-soon"],
                    ),
                    _detail(
                      "${translations["developer"]}:",
                      sidebar["developer"],
                    ),
                    _detail(
                      "${translations["publisher"]}:",
                      sidebar["publisher"],
                      topMargin: false,
                    ),
                    Span.text("${translations["tags"]}:", classes: ["detail-key"]),
                    UnorderedList(items: tags.map(ListItem.text), classes: ["tags"]),
                  ],
                ),
                Div(
                  classes: ["left-column"],
                  children: [_carousel(dirGame, dirBuildGame)],
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
          children: [
            Section(
              classes: ["game-details"],
              children: [
                _detail("${translations["title"]}:", title),
                _detail("${translations["genre"]}:", sidebar["genre"]),
                _detail("${translations["developer"]}:", sidebar["developer"]),
                _detail("${translations["publisher"]}:", sidebar["publisher"]),
                if (sidebar.optional("franchise") != null)
                  _detail("${translations["franchise"]}:", sidebar["franchise"]),
                _detail(
                  "${translations["release-date"]}:",
                  releaseDate ?? translations["coming-soon"],
                ),
                ..._sidebarButtons(sidebar),
              ],
            ),
          ],
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
            _systemRequirements(translations, dirGame),
          ],
        ),
      ],
    ),
  );

  //Copy linked images
  final List<Image> images = [];
  elements.collectOfType(into: images);
  for (final Image img in images) {
    if (img.src.contains("icons/")) continue;
    if (img.src.contains("steam_assets/")) continue;
    if (img.src.contains("/carousel/")) continue;
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

Div _detail(String key, String value, {bool topMargin = true}) {
  return Div(
    classes: ["detail"],
    inlineStyles: topMargin ? null : ["margin-top: 0"],
    children: [
      Span.text(key, classes: ["detail-key"]),
      Span.text(value, classes: ["detail-value"]),
    ],
  );
}

List<A> _sidebarButtons(KeyValueFile sidebar) {
  final values = sidebar.getWithPrefix("link-");
  return values.entries.map((entry) {
    final key = entry.key;
    const iconPrefix = "icon-";
    if (key.startsWith(iconPrefix)) {
      final text = key.replaceFirst(iconPrefix, "");
      final path = "/icons/$text.svg";
      final file = File(p.joinAll(["ssg", "copy", ...path.split("/")]));
      if (!file.existsSync()) {
        throw Exception(
          "Sidebar ${sidebar.toString(showKeys: false)} requests an icon file `${file.path}`, but it was not found!",
        );
      }
      return A(
        href: entry.value,
        classes: ["linkbar"],
        children: [
          Image(src: path, alt: text),
          Span.text(text),
          Image(src: "/steam_assets/ico_external_link.gif", alt: "External"),
        ],
      );
    }
    return A.text(
      key.replaceAll("-", " "),
      classes: ["linkbar"],
      href: entry.value,
    );
  }).toList();
}

Div _carousel(Directory dirGame, Directory dirBuildGame) {
  final dirCarousel = Directory(p.join(dirGame.path, "carousel"));
  if (!dirCarousel.existsSync()) {
    throw Exception(
      "Tried making a carousel for `${dirCarousel.path}`, but that folder does not exist!",
    );
  }
  final files = dirCarousel.listSync().whereType<File>().toList();
  if (files.isEmpty) {
    throw Exception(
      "Tried making a carousel for `${dirCarousel.path}`, but that folder is empty!",
    );
  }
  files.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

  final dirBuildCarousel = Directory(p.join(dirBuildGame.path, "carousel"))..createSync();
  final dest = p.joinAll(p.split(dirBuildCarousel.path)..removeAt(0));
  copy(dirCarousel.path, dest);

  const youtubeThumbnailPrefix = "https://img.youtube.com/vi";
  final List<Image> items = [];
  for (final file in files) {
    final String filename = p.basename(file.path);
    final int firstPeriodIndex = filename.indexOf(".");
    final String ext = filename.substring(firstPeriodIndex + 1).trim();

    switch (ext) {
      case "jpg":
      case "jpeg":
      case "png":
      case "webp":
        items.add(Image(src: "/${dest.replaceAll(r"\", "/")}/$filename", alt: ""));
      case "yt.txt":
        final String fileContent = file.readAsStringSync().trim();
        items.add(Image(src: "$youtubeThumbnailPrefix/$fileContent/default.jpg", alt: ""));
      default:
        throw Exception(
          "Tried putting `${file.path}` into a carousel, but it's of an unknown file type!",
        );
    }
  }

  return Div(
    classes: ["carousel"],
    children: [
      Div(
        classes: ["carousel-slideshow"],
        children: [],
      ),
      OrderedList(
        classes: ["carousel-preview"],
        items: items.map(
          (e) => ListItem(
            children: [e],
            classes: [
              if (e.src.startsWith(youtubeThumbnailPrefix)) "video",
            ],
          ),
        ),
      ),
    ],
  );
}

Div _systemRequirements(
  KeyValueFile translations,
  Directory dirGame,
) {
  final files = dirGame.listSync().whereType<File>().where(
    (f) => p.basename(f.path).startsWith("sysreq-"),
  );
  final LinkedHashMap<String, Div> platforms = LinkedHashMap();
  for (final file in files) {
    final fileName = p.basename(file.path);
    final platformName = fileName
        .replaceFirst(RegExp(r"^sysreq-"), "")
        .replaceFirst(RegExp(r"\.txt$"), "");
    final strLevels = file.readAsStringSync().split("\n---\n\n");
    final List<Div> levels = [];
    for (final strLevel in strLevels) {
      final lines = strLevel.trim().split("\n");
      final firstLine = lines.removeAt(0);

      final List<ListItem> items = [];
      for (final line in lines) {
        final int colonIndex = line.indexOf(":");
        if (colonIndex < 0) {
          items.add(ListItem.text(line));
        } else {
          items.add(
            ListItem(
              children: [
                Strong.text("${line.substring(0, colonIndex).trim()}:"),
                T(line.substring(colonIndex + 1).trim()),
              ],
            ),
          );
        }
      }

      levels.add(
        Div(
          classes: ["level"],
          children: [
            Strong.text(firstLine),
            UnorderedList(items: items),
          ],
        ),
      );
    }
    platforms[platformName] = Div(children: levels, classes: ["platform"]);
  }
  final List<Span> tabs = [];
  if (platforms.isNotEmpty) {
    platforms.values.first.classes = [...?platforms.values.first.classes, "active"];
    tabs.addAll(platforms.keys.map((e) => Span.text(e, classes: ["tab"])));
    tabs.first.classes = [...?tabs.first.classes, "active"];
  }
  return Div(
    classes: ["system-requirements"],
    children: [
      H2.text(translations["system-requirements"]),
      Div(classes: ["tabs"], children: tabs),
      ...platforms.values,
    ],
  );
}
