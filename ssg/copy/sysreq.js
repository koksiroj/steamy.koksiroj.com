const tabs = document.querySelectorAll(".system-requirements .tab");
const platforms = document.querySelectorAll(".system-requirements .platform");
let activeTab = document.querySelector(".system-requirements .tab.active");
let activePlatform = document.querySelector(".system-requirements .platform.active");

for (let i = 0; i < tabs.length; i++) {
	const tab = tabs[i];
	const platform = platforms[i];
	tab.addEventListener("click", () => {
		activeTab.classList.remove("active");
		activeTab = tab;
		activeTab.classList.add("active");

		activePlatform.classList.remove("active");
		activePlatform = platform;
		activePlatform.classList.add("active");
	});
}
