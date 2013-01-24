import 'dart:html';
import 'package:css_animation/css_animation.dart';


void main()
{
  // Create keyframes at 25% intervals
  var keyframes   = new Map<int, Map<String, Object>>();
  keyframes[0]    = { 'opacity': 0 };
  keyframes[25]   = { 'opacity': 1, 'left': '256px', 'background-color': '#aaf' };
  keyframes[50]   = { 'opacity': 1, 'left': '384px', 'background-color': '#aca' };
  keyframes[75]   = { 'opacity': 1, 'left': '512px', 'top': '128px', 'width': '128px', 'height': '128px' };
  keyframes[100]  = { 'opacity': 1, 'left': '630px', 'top': '256px', 'width': '256px', 'height': '256px' };

  var count = 0;
  var boxA  = query('#a');
  var boxB  = query('#b');
  var animA = new CssAnimation('top', '128px', '256px');  // Simple animation of a single property
  var animB = new CssAnimation.keyframes(keyframes);      // Fully keyframed animation

  // Animation for boxB will run indefinitely
  animB.apply(boxB,
      iterations: 0,
      alternate: true,
      duration: 2000,
      timing: CssAnimation.LINEAR
  );

  // Animation for boxA is triggered by a click and on completion
  // will append a count value inside the box.
  boxA.on.click.add((e) =>
      animA.apply(boxA,
          iterations: 2,
          alternate: true,
          onComplete: () => boxA.appendHtml(' ${count++}')
      )
  );
}
