// aside bar event
const menu = document.querySelector(".menu");
const aside = document.querySelector(".aside");
const mainContent = document.querySelector(".main-content");

menu.onclick = function () {
  aside.classList.toggle("active");
  mainContent.classList.toggle("active");
};

//check box
const slect_table = document.querySelector("#select-table");
const checkboxes = document.querySelectorAll(".checkbox");
const check_icon = document.querySelectorAll(".check-1");
for (let i = 0; i < slect_table.rows.length; i++) {
  slect_table.rows[i + 1].onclick = function () {
    checkboxes[i].checked = !checkboxes[i].checked;
    slect_table.rows[i + 1].classList.toggle("slect-row");
  };
}
// start
const button_affect_nrml = document.querySelector("#form-aff");

function affect_teachers() {
  // Récupère les cases à cocher sélectionnées
  const checkboxes = document.querySelectorAll(
    'input[name="candidat[]"]:checked'
  );
  const Teacher1 = document.querySelector("#Teacher1").value;
  console.log(Teacher1);
  const Teacher2 = document.querySelector("#Teacher2").value;
  console.log(Teacher2);
  // Récupère les codes secrets des candidats sélectionnés
  const codesSecrets = Array.from(checkboxes).map(function (checkbox) {
    return checkbox.value;
  });
  console.log(codesSecrets);

  // Envoyer une requête PUT à l'API pour mettre à jour id teacher1 teacher2 in table copy
  fetch("http://localhost:4000/users", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      teacher1ID: Teacher1,
      teacher2ID: Teacher2,
      copyIDs: codesSecrets,
    }),
  })
    .then((response) => response.json())
    .then((data) => {
      location.reload();
    });
}
function affect_third_teacher() {
  // Récupère les cases à cocher sélectionnées
  const checkboxes = document.querySelectorAll(
    'input[name="candidat1[]"]:checked'
  );
  const Teacher3 = document.querySelector("#Teacher3").value;
  console.log(Teacher3);
  // Récupère les codes secrets des candidats sélectionnés
  const codesSecrets = Array.from(checkboxes).map(function (checkbox) {
    return checkbox.value;
  });
  console.log(codesSecrets);

  // Envoyer une requête PUT à l'API pour mettre à jour  id third teacher in table copy
  fetch("/cfd-president/third-teacher", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      teacher3ID: Teacher3,
      copyIDs: codesSecrets,
    }),
  })
    .then((response) => response.json())
    .then((data) => {
      location.reload();
    });
}
