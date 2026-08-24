import "dart:io";

import "package:path/path.dart" as p;
import "package:ssg/components/head.dart";
import "package:ssg/constants.dart";
import "package:techs_html_bindings/elements.dart";

Future<void> create404() async {
  final String indexHTML = HTML(
    lang: "en",
    head: generateHead(
      title: "Page not found! | Steamy",
      description: "This page could not be found...",
      extraInlineStyles: [
        """
h1 {
	font-size: clamp(8em, min(20vw, 50vh), 20em);
  margin: 0.1em 0;
}

h1, h2, p {
	text-align: center;
	border: none;
}
""".trim(),
      ],
    ),
    body: Body(
      header: Header(children: []),
      main: Main(
        children: [
          H1.text("404"),
          P.text("This page could not be found!"),
          H2.text("Please double-check your URL.", autoLink: false),
          P(
            children: [
              T("Or go back to the "),
              A.text("Home Page", href: "/"),
            ],
          ),
        ],
      ),
      footer: Footer(children: []),
    ),
  ).build();
  File(p.join(dirBuild.path, "404.html")).writeAsStringSync(indexHTML);
}
