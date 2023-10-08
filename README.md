# 📚 MCoder 📚

There is mini-codecs collections...

## Image Decoders

### 📷 JNG (JPEG Network Graphics) 📷

Based on pure JavaScript, uses native browser-decoders.

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
import { JNG } from "/coder/index.mjs";
const $img = document.querySelector("#jng");
$img.src = URL.createObjectURL(await (new JNG().load($img.src).asPNG()));
```

### 📷 JXL (JPEG XL) 📷

Based on WebAssembly compilation.

#### About

- [En Wiki](https://en.wikipedia.org/wiki/JPEG_XL)
- [Ru Wiki](https://ru.wikipedia.org/wiki/JPEG_XL)
- [Webpage](https://jpeg.org/jpegxl/)
- [Community](https://jpegxl.info/)

#### Features

- [x] Conversion to PNG 16-bit directly
- [x] Using WebAssembly and Emscripten
- [x] Import ICC profile to PNG format
- [ ] Animation support

### API?

```js
import {loadJXL} from "/coder/index.mjs";
const $img = document.querySelector("#jxl");
$img.src = URL.createObjectURL(new Blob([await loadJXL($img.src)], {type: 'image/png'}));
```
