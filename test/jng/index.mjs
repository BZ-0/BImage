import { JNG } from "/coder/index.mjs";

//
const $img = document.querySelector("#jng");
$img.src = URL.createObjectURL(await (new JNG().load($img.src).asPNG()));
