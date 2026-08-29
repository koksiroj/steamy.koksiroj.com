const langSelect = document.querySelector("header .lang");
const langPopup = document.querySelector("header .lang-popup");
if (langSelect !== null && langPopup !== null) {
	langSelect.addEventListener("click", () => {
		langPopup.classList.toggle("active");
	});
}
