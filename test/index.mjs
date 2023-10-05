import OpenJNG from "../jng/jng.min.mjs";

//
const $img = document.querySelector("#jng");
$img.src = URL.createObjectURL(await new OpenJNG().load($img.src));
