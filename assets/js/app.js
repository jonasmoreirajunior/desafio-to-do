// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "./vendor/some-package.js"
//
// Alternatively, you can `npm install some-package` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

function focusInput(input) {
  let end = input.value.length;
  input.setSelectionRange(end, end);
  input.focus();
}

let Hooks = {}
Hooks.FocusInputItem = {
  mounted() {
    focusInput(document.getElementById("update_todo"));
  },
  updated() {
    focusInput(document.getElementById("update_todo"));
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


let msg = document.getElementById('msg');            // message input field
let form = document.getElementById('form-msg');            // message input field

// Reset todo list form input ... this is the simplest way we found ¯\_(ツ)_/¯
document.getElementById('form').addEventListener('submit', function () {
  // the setTimeout is required to let phx-submit do it's thing first ...
  setTimeout(() => { document.getElementById('new_todo').value = ""; }, 1)
});

// Function onclick all toggle checkboxs checked or unchecked
const toggleAll = document.querySelector('.toggle-all');
toggleAll.addEventListener('click', (e) => {
  const allCheckboxs = document.querySelectorAll('.toggle');
  allCheckboxs.forEach((checkbox) => {
    const parent = checkbox.closest('li');
    if (e.currentTarget.checked) {
      checkbox.checked = true;
      parent.classList.add('completed');
    } else {
      checkbox.checked = false;
      parent.classList.remove('completed');
    }
  })
})
