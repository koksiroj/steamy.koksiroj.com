const langSelect = document.querySelector("header .lang");
const langPopup = document.querySelector("header .lang-popup");
if (langSelect !== null && langPopup !== null) {
	document.addEventListener("click", (event) => {
		const clickedElement = event.target;
		if (langPopup.contains(clickedElement)) {
		} else if (clickedElement === langSelect) {
			langPopup.classList.toggle("active");
		} else {
			langPopup.classList.remove("active");
		}
	});
}
