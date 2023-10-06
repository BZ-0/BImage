# 📚 MCoder 📚

There is mini-codecs collections...

### 📷 JNG 📷

#### About

- [En Wiki](https://en.m.wikipedia.org/wiki/JPEG_Network_Graphics)
- [Ru Wiki](https://ru.m.wikipedia.org/wiki/JNG)
- [Specification](http://www.libpng.org/pub/mng/spec/jng.html)
- [JNGSuite](https://libmng.com/JNGsuite/)

#### Features

- [x] Color and gamma correction
- [x] Using OffscreenCanvas
- [x] Alpha channel support
- [x] No plugins required
- [x] Uses browser-native PNG and JPEG
- [x] Support HTML5 Canvas HDR

### API?

```js
import OpenJNG from "../jng/jng.mjs";
const $img = document.querySelector("#jng");
$img.src = URL.createObjectURL(await (new OpenJNG().load($img.src).asPNG()));
```
