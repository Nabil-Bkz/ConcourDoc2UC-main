// aside bar event
const menu = document.querySelector(".menu");
const aside = document.querySelector(".aside");
const mainContent = document.querySelector(".main-content");

menu.onclick = function () {
  aside.classList.toggle("active");
  mainContent.classList.toggle("active");
};
const publish_link = document.querySelector(".publish-link");
const mark_link = document.querySelector(".mark-link");
const table = document.querySelector(".table");
const post_container = document.querySelector(".infos ");
const list_title = document.querySelector(".list-title");

//show marks
mark_link.onclick = () => {
  mark_link.classList.add("active-link");
  publish_link.classList.remove("active-link");
  table.style.display = "block";
  post_container.style.display = "none";
  list_title.innerHTML = "Marks";
};
//show informations
publish_link.onclick = () => {
  publish_link.classList.add("active-link");
  mark_link.classList.remove("active-link");
  table.style.display = "none";
  post_container.style.display = "block";
  list_title.innerHTML = "Informations";
};
