const code = navigator.language.substring(0, 2);
const langs = document.querySelectorAll("main ul.langs > li a");
for (const lang of langs) {
	if (lang.getAttribute("href") === code) {
		lang.click();
		break;
	}
}
