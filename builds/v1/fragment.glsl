precision highp float;
uniform sampler2D iChannel0, iChannel1, iChannel2, iChannel3; //, iTexture1, iTexture2, iTexture3;
uniform vec3 iChannelResolution0, iChannelResolution1, iChannelResolution2, iChannelResolution3; //, iTexture1, iTexture2, iTexture3;
uniform samplerCube iChannel4;
uniform float iGlobalTime; // shader playback time (in seconds)
uniform vec3 iResolution; // viewport resolution (in pixels)
uniform vec4 iMouse; // mouse pixel coords. xy: current (if MLB down), zw: click
varying vec2 fragCoord, vUv; // fragCoord is the actual pixel coordinate, vUv is scaled from 0 to 1
const float PI     = 3.1415926;
const float TWO_PI = 6.2831852;

/**
 * Cubemap to Gnomonic / Rectilinear unwrapping by Ruofei Du (DuRuofei.com)
 * Link to demo: https://www.shadertoy.com/view/4sjcz1
 * starea @ ShaderToy, License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
 * https://creativecommons.org/licenses/by-nc-sa/3.0/
 *
gShaderToy.SetTexture(0, {mSrc:'https://www.dropbox.com/s/pf2rxh351esc785/mall0_5.jpg?dl=0', mType:'texture', mID:1, mSampler:{ filter: 'mipmap', wrap: 'repeat', vflip:'true', srgb:'false', internal:'byte' }});


 * Reference:
 * [1] Gnomonic projection: https://en.wikipedia.org/wiki/Gnomonic_projection
 * [2] Weisstein, Eric W. "Gnomonic Projection." From MathWorld--A Wolfram Web Resource. http://mathworld.wolfram.com/GnomonicProjection.html
 *
 **/
const float PI_2 = PI * 0.5;
const float PI2 = PI * 2.0;
const int KEY_SPACE = 32;
const int KEY_ENTER = 13;
const int KEY_1 = 49;
const int KEY_2 = 50;
const int KEY_3 = 51;
const int KEY_4 = 52;

out vec4 fragColor;

// Forked from fb39ca4's keycode viewer tool @ https://www.shadertoy.com/view/4tt3Wn
float keyPressed(int keyCode) {
	return texture(iChannel1, vec2((float(keyCode) + 0.5) / 256., .5/3.)).r;
}

// Main function, convert screen coordinate system to spherical coordinates in gnomonic projection
// screenCoord: [0, 1], centralPoint: [0, 1], FoVScale: vec2(0.9, 0.2) recommended
vec2 calcSphericalCoordsInGnomonicProjection(in vec2 screenCoord, in vec2 centralPoint, in vec2 FoVScale) {
  vec2 cp = (centralPoint * 2.0 - 1.0) * vec2(PI, PI_2);  // [-PI, PI], [-PI_2, PI_2]

  // Convert screen coord in gnomonic mapping to spherical coord in [PI, PI/2]
  vec2 convertedScreenCoord = (screenCoord * 2.0 - 1.0) * FoVScale * vec2(PI, PI_2);
  float x = convertedScreenCoord.x, y = convertedScreenCoord.y;

  float rou = sqrt(x * x + y * y), c = atan(rou);
	float sin_c = sin( c ), cos_c = cos( c );

  float lat = asin(cos_c * sin(cp.y) + (y * sin_c * cos(cp.y)) / rou);
	float lon = cp.x + atan(x * sin_c, rou * cos(cp.y) * cos_c - y * sin(cp.y) * sin_c);

	lat = (lat / PI_2 + 1.0) * 0.5; lon = (lon / PI + 1.0) * 0.5; //[0, 1]

  // convert spherical coord to cubemap coord
  return vec2(lon, lat) * vec2(PI2, PI);
}

// convert cubemap coordinates to spherical coordinates:
vec3 sphericalToCubemap(in vec2 sph) {
    return vec3(sin(sph.y) * sin(sph.x), cos(sph.y), sin(sph.y) * cos(sph.x));
}

// convert screen coordinate system to cube map coordinates in rectilinear projection
vec3 calcCubeCoordsInGnomonicProjection(in vec2 screenCoord, in vec2 centralPoint, in vec2 FoVScale) {
	return sphericalToCubemap( calcSphericalCoordsInGnomonicProjection(screenCoord, centralPoint, FoVScale) );
}

// the inverse function of calcSphericalCoordsInGnomonicProjection()
vec2 calcEquirectangularFromGnomonicProjection(in vec2 sph, in vec2 centralPoint) {
    vec2 cp = (centralPoint * 2.0 - 1.0) * vec2(PI, PI_2);
	float cos_c = sin(cp.y) * sin(sph.y) + cos(cp.y) * cos(sph.y) * cos(sph.y - cp.y);
    float x = cos(sph.y) * sin(sph.y - cp.y) / cos_c;
    float y = ( cos(cp.y) * sin(sph.y) - sin(cp.y) * cos(sph.y) * cos(sph.y - cp.y) ) / cos_c;
    return vec2(x, y) + vec2(PI, PI_2);
}

// Forked from: https://www.shadertoy.com/view/MsXGz4, press enter for comparison
vec3 iqCubemap(in vec2 q, in vec2 mo) {
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x / iResolution.y;

    // camera
	float an1 = -6.2831 * (mo.x + 0.25);
	float an2 = clamp( (1.0-mo.y) * 2.0, 0.0, 2.0 );
    vec3 ro = 2.5 * normalize(vec3(sin(an2)*cos(an1), cos(an2)-0.5, sin(an2)*sin(an1)));
    vec3 ww = normalize(vec3(0.0, 0.0, 0.0) - ro);
    vec3 uu = normalize(cross( vec3(0.0, -1.0, 0.0), ww ));
    vec3 vv = normalize(cross(ww, uu));
    return normalize( p.x * uu + p.y * vv + 1.4 * ww );
}

void main()
{
	vec2 q = fragCoord.xy / iResolution.xy;

	// Modify this to adjust the field of view
  vec2 FoVScale = vec2(0.45, 0.4);
  FoVScale = vec2(0.5, 0.5);

  // central / foveated point, iMouse.xy corresponds to longitude and latitude
  vec2 centralPoint = iMouse.xy / iResolution.xy;
  //vec2(0.25, 0.5)
  // press enter to compare with iq's cubemaps https://www.shadertoy.com/view/MsXGz4
  vec2 dir = calcSphericalCoordsInGnomonicProjection(q, centralPoint, FoVScale) / vec2(PI2, PI);
	vec3 col = texture(iChannel0, dir).rgb;

  col *= 0.25 + 0.75 * pow( 16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.15 );
  fragColor = vec4(col, 1.0);
}
