attribute vec2 aPosition;
varying vec2 viewPortPosition;
uniform vec2 uResolution;
 
void main() {
  viewPortPosition = vec2(aPosition.x - uResolution.x / 2.0, aPosition.y - uResolution.y / 2.0);
  vec2 zeroToOne = aPosition / uResolution;
  vec2 zeroToTwo = zeroToOne * 2.0;
  vec2 clipSpace = zeroToTwo - 1.0;
  gl_Position = vec4(clipSpace, 0, 1);
}