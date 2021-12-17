<!doctype html>
<html lang="en">

<head>
  <title>DuPano - An online panorama viewer.</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
  <style>
    body {
      background-color: #000;
      color: #fff;
      margin: 0px;
      padding: 0;
      overflow: hidden;
    }
  </style>
</head>

<body onmousemove="handleMouseMove(event)">
  <script src="js/three.min.js"></script>
  <script src="js/video.js"></script>
  <div id="GL" style="position: absolute; left:0px; top:0px; background-color: #f00;"></div>
