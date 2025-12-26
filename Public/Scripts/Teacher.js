// aside bar event
const menu = document.querySelector(".menu");
const aside = document.querySelector(".aside");
const mainContent = document.querySelector(".main-content");

menu.onclick = function () {
  aside.classList.toggle("active");
  mainContent.classList.toggle("active");
};
// send marks
function envoyerNotes() {
  var table = document.getElementsByTagName("table")[0];
  var rows = table.rows;

  var notes = [];
  for (var i = 1; i < rows.length; i++) {
    var codeSecret = rows[i].cells[0].innerHTML;
    var noteInput = rows[i].getElementsByTagName("input")[0];
    var note = noteInput.value;

    notes.push({
      copyID: codeSecret,
      mark: Number(note),
    });
  }
  notes = notes.filter((note) => note.mark != 0);
  console.log(notes);
  // put api to send marks
  fetch("/teacher", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(notes),
  })
}
