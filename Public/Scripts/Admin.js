// aside bar event
const menu = document.querySelector(".menu");
const aside = document.querySelector(".aside");
const mainContent = document.querySelector(".main-content");

menu.onclick = function () {
  aside.classList.toggle("active");
  mainContent.classList.toggle("active");
};
// add button event
const add_admin_button = document.querySelector(".add-button");
const main = document.querySelector(".main");
const add_form = document.querySelector(".add-form");
const close = document.querySelector(".close");
const add_link = document.querySelector(".add-link");
const administrator_link = document.querySelector(".administrator-link");
const condidat_link = document.querySelector(".condidat-link");
const employee_link = document.querySelector(".employee-link");
//show add form

add_admin_button.onclick = function () {
  main.classList.toggle("active-add-form");
  menu.classList.toggle("active-add-form");
  add_form.classList.toggle("active-add-form");
};

//close add form
close.onclick = function () {
  main.classList.remove("active-add-form");
  menu.classList.remove("active-add-form");
  add_form.classList.remove("active-add-form");
  edit_form.classList.remove("active-add-form");
};

// edit form event
//show edit form
const edit_form = document.querySelector(".edit-form");
const edit_button = document.querySelectorAll(".edit-button");
// edit user function get uesr form api
function editUser(userId) {
  // Envoyer une requête GET à l'API pour récupérer les informations de l'utilisateur
  fetch("/admin/" + userId)
    .then((response) => response.json())
    .then((data) => {
      // Remplir les champs du formulaire avec les informations de l'utilisateur

      document.querySelector(".firstName-edit").value = data.firstName;
      document.querySelector(".LastName-edit").value = data.lastName;
      document.querySelector(".email-edit").value = data.email;
      document.querySelector(".UserType-edit").value = data.type;
      document.querySelector(".userId-Edit").value = data.id;

      // Afficher le formulaire

      main.classList.add("active-add-form");
      menu.classList.add("active-add-form");
      edit_form.classList.add("active-add-form");
    });
}

// end edit user function
// close edit from
const close_edit = document.querySelector(".close-edit");
close_edit.onclick = function () {
  main.classList.remove("active-add-form");
  menu.classList.remove("active-add-form");
  edit_form.classList.remove("active-add-form");
};

const table_employee = document.querySelector(".table.table-employee");
const table_admin = document.querySelector(".table.table-admin");
const table_condidat = document.querySelector(".table.table-condidat");
const list_title = document.querySelector(".list-title");
const btn = document.querySelector(".btn");
//employee list show

employee_link.onclick = function () {
  employee_link.classList.add("active-link");
  administrator_link.classList.remove("active-link");
  condidat_link.classList.remove("active-link");
  table_employee.style.display = "block";
  table_admin.style.display = "none";
  table_condidat.style.display = "none";
  list_title.innerHTML = "Employees";
};
//condidat list show

condidat_link.onclick = function () {
  employee_link.classList.remove("active-link");
  administrator_link.classList.remove("active-link");
  condidat_link.classList.add("active-link");
  table_employee.style.display = "none";
  table_admin.style.display = "none";
  table_condidat.style.display = "block";
  list_title.innerHTML = "Candidates";
};
//admin list show

administrator_link.onclick = function () {
  employee_link.classList.remove("active-link");
  administrator_link.classList.add("active-link");
  condidat_link.classList.remove("active-link");
  table_employee.style.display = "none";
  table_admin.style.display = "block";
  table_condidat.style.display = "none";
  list_title.innerHTML = "Admins";
};
const csvFile = document.querySelector(".csvFile");
const csv_button = document.querySelector(".add-csv-link");

// update user api
function saveUser() {
  // Récupérer les informations du formulaire
  const firstName = document.querySelector(".firstName-edit").value;
  const lastName = document.querySelector(".LastName-edit").value;
  const email = document.querySelector(".email-edit").value;
  const type = document.querySelector(".UserType-edit").value;
  const userId = document.querySelector(".userId-Edit").value;

  // Envoyer une requête PUT à l'API pour mettre à jour l'utilisateur
  fetch("/admin/" + userId, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      firstName: firstName,
      lastName: lastName,
      email: email,
      type: type,
    }),
  })
    .then((response) => response.json())
    .then((data) => {
      // Cacher le formulaire
      main.classList.remove("active-add-form");
      menu.classList.remove("active-add-form");
      edit_form.classList.remove("active-add-form");
      // Rafraîchir la page pour afficher les informations mises à jour
      location.reload();
    });
}

const save_csv = document.querySelector(".save-csv");

//csvFile upload show

csv_button.onclick = function () {
  main.classList.toggle("active-add-form");
  menu.classList.toggle("active-add-form");
  csvFile.style.display = "block";
};
//csvFile upload close
const closee = document.querySelector(".closee");
closee.onclick = function () {
  main.classList.remove("active-add-form");
  menu.classList.remove("active-add-form");
  csvFile.style.display = "none";
};
// csv file uploaded file start api csv
const csv_form = document.querySelector(".csv-form");
const input_file = document.querySelector(".input-file");
const progress_area = document.querySelector(".progress-area");
const uploaded_area = document.querySelector(".row-display ");
const name_file = document.querySelector(".name-file");
const size = document.querySelector(".size");

csv_form.addEventListener("click", () => {
  input_file.click();
});

input_file.addEventListener("change", (event) => {
  const file = event.target.files[0];

  let file_name = file.name;
  name_file.innerHTML = `${file.name}`;
  uploaded_area.style.display = "block";
});
/*************** */

input_file.addEventListener("change", (event) => {
  event.preventDefault();
  const file = event.target.files[0];

  const reader = new FileReader();
  reader.readAsText(file);
  reader.onload = () => {
    let csv = reader.result;

    const lines = csv.split("\n"); // Sépare le contenu du fichier en lignes
    const headers = lines[0].split(","); // Sépare la première ligne (les en-têtes) en colonnes
    const candidates = [];

    for (let i = 1; i < lines.length; i++) {
      const columns = lines[i].split(","); // Sépare chaque ligne en colonnes

      const candidate = {};

      for (let j = 0; j < headers.length; j++) {
        candidate[headers[j]] = columns[j]; // Ajoute chaque colonne à l'objet candidat
      }

      candidates.push(candidate); // Ajoute l'objet candidat à la liste des candidats
    }
      candidates.pop()
      console.log(candidates)

    fetch("/admin/batchCreate", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(candidates),
    })
  };
});
// csv file uploaded file end api csv
