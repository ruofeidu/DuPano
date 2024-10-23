# DuPano

A drag-and-drop panorama viewer.
Deployed in <https://tool.duruofei.com/360viewer/>

## Interaction

* space key to toggle animation.
* double click to toggle fullscreen.
* add `?src=<url>` to the url to load an image (requires PHP, or server code for cross-origin access)

## v1

Run `python build.py` to build `index.html`.

Built upon my prior code to render a quad.

## v2

Built largely upon <https://github.com/mrdoob/three.js/blob/master/examples/webgl_panorama_equirectangular.html> with adaptive resolution.

## TODO

Supports video as well, v1 and three.js have some code to reuse. Please feel free to contribute as I am not that motivated.

## License

CC0, do whatever you want.
