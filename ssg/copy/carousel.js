const youtubeThumbnailPrefix = "https://img.youtube.com/vi/";
const slideshow = document.querySelector(".carousel-slideshow");
const listItems = document.querySelectorAll(".carousel-preview > li");
let activeItem = listItems[0];
selectItem(activeItem);

for (const listItem of listItems) {
	listItem.addEventListener("click", () => {
		selectItem(listItem);
	});
}

function selectItem(selectedItem) {
	activeItem.classList.remove("active");
	activeItem = selectedItem;
	activeItem.classList.add("active");

	const image = activeItem.querySelector("img");
	if (image.src.startsWith(youtubeThumbnailPrefix)) {
		const newEmbed = document.createElement("iframe");
		const videoID = image.src.replace(youtubeThumbnailPrefix, "").replace("/default.jpg", "");
		newEmbed.src = `https://www.youtube-nocookie.com/embed/${videoID}`;
		newEmbed.allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share";
		newEmbed.referrerPolicy = "strict-origin-when-cross-origin";
		newEmbed.allowFullscreen = true;

		const loadingIndicator = document.createElement("img");
		loadingIndicator.src = "/loading.svg";
		loadingIndicator.alt = "Loading...";
		loadingIndicator.classList.add("loading-indicator");

		newEmbed.onload = () => loadingIndicator.remove();
		slideshow.replaceChildren(loadingIndicator, newEmbed);
	} else {
		const newImage = document.createElement("img");
		newImage.src = image.src;
		newImage.alt = image.alt;
		slideshow.replaceChildren(newImage);
	}
}
