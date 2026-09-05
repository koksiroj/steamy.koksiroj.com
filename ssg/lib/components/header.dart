import "package:ssg/key_value_file.dart";
import "package:ssg/languages.dart";
import "package:techs_html_bindings/elements.dart";

Header generateHeader(
  Language language,
  KeyValueFile translations, {
  List<A> languageLinks = const [],
}) {
  if (languageLinks.length > 1) {
    languageLinks.sort((a, b) => a.innerText.compareTo(b.innerText));
  }
  return Header(
    children: [
      Div(
        classes: ["content"],
        children: [
          A(
            href: "/${language.code}",
            children: [
              T("Steamy"),
            ],
            classes: ["branding"],
          ),
          Div(
            classes: ["tab-links"],
            children: [
              A.text(translations["header-store"], href: "/${language.code}"),
              A.text(translations["header-community"], href: "#"),
              A.text(translations["header-about"], href: "#"),
              A.text(translations["header-support"], href: "#"),
            ],
          ),
          if (languageLinks.length > 1) ...[
            A.text(
              classes: ["lang"],
              translations["header-language"],
              href: "#",
            ),
            UnorderedList(
              classes: ["lang-popup"],
              items: languageLinks.map((a) => ListItem(children: [a])),
            ),
          ],
        ],
      ),
    ],
  );
}
