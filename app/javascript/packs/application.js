// // This file is automatically compiled by Webpack, along with any other files
// // present in this directory. You're encouraged to place your actual application logic in
// // a relevant structure within app/javascript and only use these pack files to reference
// // that code so it'll be compiled.

// import Rails from "@rails/ujs"
// import Turbolinks from "turbolinks"
// import * as ActiveStorage from "@rails/activestorage"
// import "channels"

// // Bootstrap、jQuery、Popper.jsのインポート
// import 'bootstrap'
// import 'jquery'
// import 'popper.js'

// document.addEventListener("turbolinks:load", () => {
//   Rails.start()
// })

// Turbolinks.start()
// ActiveStorage.start()
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

// jQuery、Popper.js、Bootstrapのインポート（順序に注意）
import 'jquery'
import 'bootstrap'
import '@popperjs/core'

// stylesheets/application.scssをインポート
import "../stylesheets/application.scss";


// Rails、Turbolinks、ActiveStorage の起動
Rails.start()
Turbolinks.start()
ActiveStorage.start()

// Turbolinks読み込み後のイベント処理
document.addEventListener("turbolinks:load", () => {
  console.log("Turbolinks loaded!");
});
