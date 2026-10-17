# DuPano

A drag-and-drop panorama viewer.
Deployed in <https://tool.duruofei.com/360viewer/>

## Interaction

* drag to look around, scroll to zoom.
* space key to toggle animation.
* double click (or `F`) to toggle fullscreen.
* press `S` (or the camera button) to save a snapshot of the current view as a PNG.
* press `i` to see all keyboard shortcuts.
* add `?src=<url>` to the url to load an image (requires PHP, or server code for cross-origin access)

### Desktop viewing modes (XR Blocks simulator)

Insta360-style projections, switchable from the on-screen toolbar or the
keyboard. Switching animates with a smooth cross-fade. **XR / AR mode keeps the
original inside-the-sphere experience unchanged.**

| Mode | Key | Description |
| --- | --- | --- |
| Dewarp | `D` / `1` | Normal rectilinear view (default) |
| MEGA | `M` / `2` | Wide-angle |
| ULTRA | `U` / `3` | Ultra-wide fisheye |
| Crystal Ball | `C` / `4` | Ray-traced glass ball refracting the scene |
| Tiny Planet | `T` / `5` | Little-planet stereographic |
| Equirect | `E` / `6` | Flat equirectangular 360 strip |

Use `[` / `]` to cycle between modes.

## v1

Run `python build.py` to build `index.html`.

Built upon my prior code to render a quad.

## v2

Built largely upon <https://github.com/mrdoob/three.js/blob/master/examples/webgl_panorama_equirectangular.html> with adaptive resolution.

## TODO

Supports video as well, v1 and three.js have some code to reuse. Please feel free to contribute as I am not that motivated.

## License

CC0, do whatever you want.
# DuReviewBot
