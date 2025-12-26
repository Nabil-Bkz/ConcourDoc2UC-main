/* show marks form */
const closer = document.querySelector(".closer");
const annuler = document.querySelector(".annuler");
const show_Marks = document.querySelector(".show-Marks");
const publish_link = document.querySelector(".publish-link");
closer.onclick = () => {
  show_Marks.style.display = "none";
};
annuler.onclick = (event) => {
  event.preventDefault();
  show_Marks.style.display = "none";
};
publish_link.onclick = (event) => {
  event.preventDefault();
  show_Marks.style.display = "block";
};
/* show marks form */
// publish marks
function publishMarks() {
  var table = document.querySelector("#table-final");
  var rows = table.rows;

  var final_marks = [];
  for (var i = 1; i < rows.length; i++) {
    for (var j = i + 1; j < rows.length; j++) {
      if (rows[i].cells[0].innerHTML == rows[j].cells[0].innerHTML) {
        infoFinalMark = rows[j].cells[6].innerHTML;
        mathFinalMark = rows[i].cells[6].innerHTML;
        candidateID = rows[i].cells[0].innerHTML;
        final_marks.push({
          candidateID: candidateID,
          infoFinalMark: Number(infoFinalMark),
          mathFinalMark: Number(mathFinalMark),
        });
      }
    }
  }
    
    console.log(final_marks)

  // put api to send final marks
  fetch("/cfd-president/copies/marked/new", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(final_marks),
  })
    .then((response) => response.json())
    .then((data) => {
      location.reload();
    });
}
