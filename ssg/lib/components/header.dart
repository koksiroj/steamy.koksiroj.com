import "package:ssg/languages.dart";
import "package:techs_html_bindings/elements.dart";

Header generateHeader(Translations translations) {
  return Header(
    children: [
      Div(
        classes: ["content"],
        children: [
          A(
            href: "/en",
            children: [
              T("Steamy"),
            ],
            classes: ["branding"],
          ),
          Div(
            classes: ["tab-links"],
            children: [
              A.text(translations["header-store"], href: "#"),
              A.text(translations["header-community"], href: "#"),
              A.text(translations["header-about"], href: "#"),
              A.text(translations["header-support"], href: "#"),
            ],
          ),
          A.text(translations["header-language"], href: "#", classes: ["langs"]),
        ],
      ),
    ],
  );
}
