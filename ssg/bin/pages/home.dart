import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/head.dart";
import "package:ssg/components/header.dart";
import "package:ssg/constants.dart";
import "package:ssg/key_value_file.dart";
import "package:ssg/languages.dart";
import "package:techs_html_bindings/elements.dart";

void createHomePages() {
  for (final Language language in languages) {
    _createHomePage(language);
  }
}

void _createHomePage(Language language) {
  final String indexHTML = HTML(
    lang: language.code,
    head: generateHead(
      title: "Steamy Store",
      description: "",
      extraStyles: ["header", "home"],
      scriptFiles: ["/lang-select.js"],
    ),
    body: _generateBody(language),
  ).build();

  final Directory dirBuildLanguage = Directory(p.join(dirBuild.path, language.code))..createSync();
  File(p.join(dirBuildLanguage.path, "index.html")).writeAsStringSync(indexHTML);
}

Body _generateBody(Language language) {
  final dirsGames = language.directory.listSync().whereType<Directory>().toList();
  dirsGames.sort((dirA, dirB) {
    final fileTitleA = File(p.join(dirA.path, "title.txt"));
    final String titleA = fileTitleA.readAsStringSync().trim();
    final fileTitleB = File(p.join(dirB.path, "title.txt"));
    final String titleB = fileTitleB.readAsStringSync().trim();

    final fileLinkA = File(p.join(dirA.path, "link.txt"));
    final fileLinkB = File(p.join(dirB.path, "link.txt"));

    // If they're both the same "level", aka both are links or neither are links
    if ((fileLinkA.existsSync() && fileLinkB.existsSync()) ||
        (!fileLinkA.existsSync() && !fileLinkB.existsSync())) {
      return titleA.compareTo(titleB);
    } else {
      // They're not the same level, so the one that is a link should be prioritised
      if (fileLinkA.existsSync()) return -1;
      if (fileLinkB.existsSync()) return 1;
    }
    return 0;
  });
  final translations = KeyValueFile(File(p.join(language.directory.path, "translations.yaml")));
  return Body(
    header: generateHeader(
      language,
      translations,
      languageLinks: languages.map((lang) => A.text(lang.display, href: "/${lang.code}")).toList(),
    ),
    main: Main(
      children: [
        UnorderedList(
          classes: ["games"],
          items: dirsGames.map((dir) {
            final fileTitle = File(p.join(dir.path, "title.txt"));
            final String title = fileTitle.readAsStringSync().trim();

            final fileLink = File(p.join(dir.path, "link.txt"));
            final String link;
            if (fileLink.existsSync()) {
              link = fileLink.readAsStringSync().trim();
              final uri = Uri.parse(link); //verify that it's an actual proper link
              if (uri.authority != "store.steampowered.com") {
                throw Exception(
                  "The URL in `${fileLink.path} is not a valid `store.steampowered.com` URL!",
                );
              }
            } else {
              link = p.basename(dir.path);
            }
            return _gameCard(
              title: title,
              link: link,
              dir: dir,
              translations: translations,
            );
          }),
        ),
      ],
    ),
    footer: Footer(children: []),
  );
}

ListItem _gameCard({
  required String title,
  required String link,
  required Directory dir,
  required KeyValueFile translations,
}) {
  final fileTags = File(p.join(dir.path, "tags.txt"));
  final String tags = fileTags.readAsStringSync().trim();

  final fileReleaseDate = File(p.join(dir.path, "release_date.txt"));
  final String? releaseDate = fileReleaseDate.existsSync()
      ? fileReleaseDate.readAsStringSync().trim()
      : null;

  final filePrice = File(p.join(dir.path, "price.txt"));
  Div? priceTag;
  if (filePrice.existsSync()) {
    final String price = filePrice.readAsStringSync().trim();
    priceTag = Div(
      classes: ["game-content-column", "game-price"],
      children: [
        P.text(price),
      ],
    );
  }

  return ListItem(
    children: [
      A(
        href: link,
        classes: ["game-card"],
        children: [
          Image(src: "${p.basename(dir.path)}/store_capsule_small.jpg", alt: ""),
          Div(
            classes: ["game-content"],
            children: [
              Div(
                classes: ["game-content-column", "game-info"],
                children: [
                  H3.text(title),
                  P.text(tags, classes: ["tags"]),
                  P.text(
                    releaseDate == null
                        ? translations["coming-soon"]
                        : "${translations["released"]}: $releaseDate",
                    classes: ["released"],
                  ),
                ],
              ),
              ?priceTag,
            ],
          ),
        ],
      ),
    ],
  );
}
