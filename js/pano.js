import * as THREE from "./three.module.min.js";

let camera, scene, renderer;
let autoRotating = true;
let imageWidth = 1920,
  imageHeight = 1080,
  imageToUpdate = null,
  imageNeedsUpdate = false;
let material, texture;

var imgDropBuffer = document.createElement("img");
imgDropBuffer.classList.add("obj");

let isUserInteracting = false,
  onPointerDownMouseX = 0,
  onPointerDownMouseY = 0,
  lon = 0,
  onPointerDownLon = 0,
  lat = 0,
  onPointerDownLat = 0,
  phi = 0,
  theta = 0;

Mousetrap.bind("space", function () {
  autoRotating = !autoRotating;
});

init();
animate();

function init() {
  const container = document.getElementById("container");

  camera = new THREE.PerspectiveCamera(
    75,
    window.innerWidth / window.innerHeight,
    1,
    1100
  );

  scene = new THREE.Scene();

  const geometry = new THREE.SphereGeometry(500, 60, 40);
  // invert the geometry on the x-axis so that all of the faces point inward
  geometry.scale(-1, 1, 1);

  const queryString = window.location.search;
  const urlParams = new URLSearchParams(queryString);
  const src = urlParams.get("src");

  texture = new THREE.TextureLoader().load(src || "presets/panorama.png");
  material = new THREE.MeshBasicMaterial({ map: texture });

  const mesh = new THREE.Mesh(geometry, material);

  scene.add(mesh);

  renderer = new THREE.WebGLRenderer();
  renderer.setPixelRatio(window.devicePixelRatio);
  renderer.setSize(window.innerWidth, window.innerHeight);
  container.appendChild(renderer.domElement);

  container.style.touchAction = "none";
  container.addEventListener("pointerdown", onPointerDown);

  document.addEventListener("wheel", onDocumentMouseWheel);

  //

  document.addEventListener("dragover", function (event) {
    event.preventDefault();
    event.dataTransfer.dropEffect = "copy";
  });

  document.addEventListener("dragenter", function () {
    document.body.style.opacity = 0.5;
  });

  document.addEventListener("dragleave", function () {
    document.body.style.opacity = 1;
  });

  document.addEventListener("drop", function (event) {
    event.preventDefault();

    const reader = new FileReader();
    // reader.addEventListener("load", function (event) {
    //   material.map.image.src = event.target.result;
    //   material.map.needsUpdate = true;
    // });
    reader.readAsDataURL(event.dataTransfer.files[0]);

    reader.onload = (function (aImg) {
      return function (e) {
        aImg.src = e.target.result;
        setTimeout(function () {
          imageWidth = aImg.width;
          imageHeight = aImg.height;
          imageToUpdate = e.target.result;
          imageNeedsUpdate = true;
          console.log(aImg.width); // right now file already loaded...
        }, 100);
      };
    })(imgDropBuffer);

    document.body.style.opacity = 1;
  });

  //

  window.addEventListener("resize", onWindowResize);
}

function onWindowResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();

  renderer.setSize(window.innerWidth, window.innerHeight);
}

function onPointerDown(event) {
  if (event.isPrimary === false) return;

  isUserInteracting = true;

  onPointerDownMouseX = event.clientX;
  onPointerDownMouseY = event.clientY;

  onPointerDownLon = lon;
  onPointerDownLat = lat;

  document.addEventListener("pointermove", onPointerMove);
  document.addEventListener("pointerup", onPointerUp);
}

function onPointerMove(event) {
  if (event.isPrimary === false) return;

  lon = (onPointerDownMouseX - event.clientX) * 0.1 + onPointerDownLon;
  lat = (event.clientY - onPointerDownMouseY) * 0.1 + onPointerDownLat;
}

function onPointerUp() {
  if (event.isPrimary === false) return;

  isUserInteracting = false;

  document.removeEventListener("pointermove", onPointerMove);
  document.removeEventListener("pointerup", onPointerUp);
}

function onDocumentMouseWheel(event) {
  const fov = camera.fov + event.deltaY * 0.05;

  camera.fov = THREE.MathUtils.clamp(fov, 10, 75);

  camera.updateProjectionMatrix();
}

function animate() {
  requestAnimationFrame(animate);
  update();
}

function update() {
  if (imageNeedsUpdate) {
    if (
      imageWidth !== material.map.width ||
      imageHeight !== material.map.height
    ) {
      material.map = new THREE.TextureLoader().load(imageToUpdate);
    }
    imageNeedsUpdate = false;
    // material.map.image.src = imageToUpdate;
    material.map.needsUpdate = true;
  }

  if (isUserInteracting === false && autoRotating) {
    lon += 0.1;
  }

  lat = Math.max(-85, Math.min(85, lat));
  phi = THREE.MathUtils.degToRad(90 - lat);
  theta = THREE.MathUtils.degToRad(lon);

  const x = 500 * Math.sin(phi) * Math.cos(theta);
  const y = 500 * Math.cos(phi);
  const z = 500 * Math.sin(phi) * Math.sin(theta);

  camera.lookAt(x, y, z);

  renderer.render(scene, camera);
}

// Fullscreen feature.
function toggleFullscreen() {
  let v = document.getElementById("container");
  if (!document.webkitFullscreenElement) {
    if (v.requestFullScreen) {
      v.requestFullScreen();
    } else if (v.webkitRequestFullScreen) {
      v.webkitRequestFullScreen();
    } else if (v.mozRequestFullScreen) {
      v.mozRequestFullScreen();
    }
  } else {
    document.webkitExitFullscreen();
  }
}

document
  .getElementById("container")
  .addEventListener("dblclick", toggleFullscreen);
