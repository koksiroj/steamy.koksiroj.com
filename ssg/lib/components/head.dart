import "package:ssg/constants.dart";
import "package:techs_html_bindings/elements.dart";

Head generateHead({
  required String title,
  required String description,
  List<String> extraStyles = const [],
  List<Link> extraLinks = const [],
  List<String> extraInlineStyles = const [],
}) {
  return Head(
    title: title,
    metas: [
      Meta.property("og:title", content: title),
      Meta.name("description", content: description),
      Meta.property("og:description", content: description),
      Meta.name("theme-color", content: "#1B2838"),
      Meta.property("og:image", content: "$baseUrl/icon-128.png"),
      Meta.httpEquiv("X-Clacks-Overhead", content: "GNU Terry Pratchett"),
      Meta.name("darkreader-lock", content: null),
    ],
    links: [
      Link.icon(type: "image/png", sizes: "48x48", href: "/favicon48.png"),
      Link.icon(type: "image/png", sizes: "32x32", href: "/favicon32.png"),
      Link.icon(type: "image/png", sizes: "16x16", href: "/favicon16.png"),
      ...Link.preloadedStylesheet(href: "/styles/shared.css"),
      ...extraStyles.expand(
        (String extraStyle) => Link.preloadedStylesheet(href: "/styles/$extraStyle.css"),
      ),
      ...extraLinks,
    ],
    styles: [
      Style(css: "html { background: #1B2838; }"),
      ...extraInlineStyles.map((str) => Style(css: str)),
    ],
  );
}
