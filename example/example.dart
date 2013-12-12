import 'dart:html';
import 'package:css_animation/css_animation.dart';


void main()
{
  // Create keyframes at 25% intervals
  var keyframes   = new Map<int, Map<String, Object>>();
  keyframes[0]    = { 'opacity': 0 };
  keyframes[25]   = { 'opacity': 1, 'left': '256px', 'background-color': '#aaf' };
  keyframes[50]   = { 'opacity': 1, 'left': '384px', 'background-color': '#aca' };
  keyframes[75]   = { 'opacity': 1, 'left': '512px', 'top': '196px', 'width': '128px', 'height': '128px' };
  keyframes[100]  = { 'opacity': 1, 'left': '630px', 'top': '256px', 'width': '256px', 'height': '256px' };

  var count = 0;
  var boxA  = querySelector('#a');
  var boxB  = querySelector('#b');
  var line  = querySelector('#line');
  var animA = new CssAnimation('top', '196px', '256px');  // Simple animation of a single property
  var animB = new CssAnimation.keyframes(keyframes);      // Fully keyframed animation

  // Animation for boxB will run indefinitely
  animB.apply(boxB,
      iterations: 0,
      alternate: true,
      duration: 2000,
      timing: CssAnimation.LINEAR
  );

  // You can pause or resume the animation by adjusting the play state:
  boxB.onClick.listen((e) =>
      boxB.style.animationPlayState = boxB.style.animationPlayState == 'paused' ? 'running' : 'paused'
  );

  // Animation for boxA is triggered by a click and on completion
  // will append a count value inside the box.
  boxA.onClick.listen((e) =>
      animA.apply(boxA,
          iterations: 2,
          alternate: true,
          duration: 500,
          onComplete: () => boxA.appendHtml(' ${count++}')
      )
  );

  // Individual properties at specific keyframes can be modified.
  // Will take effect next time the animation is applied to an element.
  int top = 320;
	querySelector('#buttonA').onClick.listen((e) {
    animA.modify(100, 'top', '${top}px');
    line.style.top = '${top + 138}px';
    top += 64;
  });

  // Entire property maps at specific keyframes can be replaced.
	querySelector('#buttonB').onClick.listen((e) {
    boxB.style.animation = 'none';
    animB.replace(50, { 'opacity': 0.25, 'background-color': '#fff', 'font-size': '48px' });
    animB.apply(boxB, iterations: 0, alternate: true, duration: 2000, timing: CssAnimation.LINEAR);
  });
}
