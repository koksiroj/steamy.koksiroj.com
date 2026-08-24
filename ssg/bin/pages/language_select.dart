import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/head.dart";
import "package:ssg/constants.dart";
import "package:techs_html_bindings/elements.dart";

void createLanguageSelectPage() {
  final String indexHTML = HTML(
    lang: "en",
    head: generateHead(
      title: "Steamy Language Select",
      description: "",
      extraStyles: ["language_select"],
    ),
    body: _generateBody(),
  ).build();
  File(p.join(dirBuild.path, "index.html")).writeAsStringSync(indexHTML);
}

Body _generateBody() {
  return Body(
    header: Header(children: []),
    main: Main(
      children: [
        UnorderedList(
          classes: ["langs"],
          items: [
            ListItem(children: [A.text("English", href: "en")]),
            ListItem(children: [A.text("Nederlands", href: "nl")]),
          ],
        ),
      ],
    ),
    footer: Footer(children: []),
  );
}
