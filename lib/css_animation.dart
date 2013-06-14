// Copyright (c) 2013, Dan Parnham. All rights reserved. Use of this source code
// is governed by a BSD-style licence that can be found in the LICENSE file.

library css_animation;

import 'dart:html';
import 'dart:html_common';


/// Callback function type
typedef void CssAnimationComplete();


///
/// CssAnimation is a helper class aiming to simplify the use
/// of CSS3 animations.
///
/// This builds and injects a rule into the stylesheets that
/// defines the keyframes of the animation. This rule can then
/// be applied to an element. Be aware that the rules are not
/// deleted when an instance is destroyed, therefore generating
/// instances continuously is probably a bad idea.
///
class CssAnimation
{
  /// Timing function constants
  static const String LINEAR          = 'linear';
  static const String EASE            = 'ease';
  static const String EASE_IN         = 'ease-in';
  static const String EASE_OUT        = 'ease-out';
  static const String EASE_IN_OUT     = 'ease-in-out';

  static int _reference                     = 0;
  static StyleElement _style                = new StyleElement();
  Text _rule                                = new Text('');
  Map<int, Map<String, Object>> _keyframes  = null;
  int _id                                   = _reference++;
  String _name;


  ///
  /// Simple constructor defining the animation of a single CSS property.
  ///
  /// This will automatically generate the start and end keyframes
  /// required to animate the CSS [property] [from] one value [to]
  /// the next. e.g.,
  ///
  ///    var anim = new CssAnimation('opacity', 0, 1);
  ///
  CssAnimation(String property, Object from, Object to)
  {
    var keyframes   = new Map<int, Map<String, Object>>();
    keyframes[0]    = new Map<String, Object>()..[property] = from;
    keyframes[100]  = new Map<String, Object>()..[property] = to;

    this._buildRule(keyframes);
  }


  ///
  /// Returns an instance that defines the animation of multiple CSS properties.
  ///
  /// Start and end keyframes will be generated using the [from] and [to]
  /// maps of CSS properties. e.g.,
  ///
  ///     var anim = new CssAnimation.properties(
  ///         { 'visibility' : 'hidden', 'opacity' : 0 },
  ///         { 'visibility' : 'visible', 'opacity' : 1 }
  ///     );
  ///
  CssAnimation.properties(Map<String, Object> from, Map<String, Object> to)
  {
    var keyframes   = new Map<int, Map<String, Object>>();
    keyframes[0]    = from;
    keyframes[100]  = to;

    this._buildRule(keyframes);
  }


  ///
  /// Returns an instance that defines each keyframe of the animation.
  ///
  /// The [keyframes] map has an integer key that must lie between 0 and 100
  /// representing the percentage progress through the animation. At each of
  /// these keyframes it defines a set of CSS properties and their
  /// corresponding values. e.g.,
  ///
  ///     var keyframes   = new Map<int, Map<String, Object>>();
  ///     keyframes[0]    = { 'opacity': 0, 'top': '0px' };
  ///     keyframes[25]   = { 'opacity': 1, 'top': '0px' };
  ///     keyframes[75]   = { 'opacity': 1, 'top': '32px' };
  ///     keyframes[100]  = { 'opacity': 0, 'top': '32px' };
  ///     var anim        = new CssAnimation.keyframes(keyframes);
  ///
  /// The above example will create an animation that fades an element in,
  /// moves it down 32px and then fades it back out again.
  ///
  CssAnimation.keyframes(Map<int, Map<String, Object>> keyframes)
  {
    if (keyframes.containsKey(0) && keyframes.containsKey(100))
    {
      if (keyframes.keys.every((k) => k >= 0 && k <= 100))
      {
        this._buildRule(keyframes);
      }
      else throw 'Animation keyframes must lie in the range 0 to 100';
    }
    else throw 'Animation should have a start (0) and finish (100)';
  }


  /// Builds the rule that is injected into the stylesheets
  void _buildRule(Map<int, Map<String, Object>> keyframes)
  {
    if (this._name == null)
    {
      this._name = 'css-animation-${_id}';
      _style.nodes.add(this._rule);

      if (_style.parent == null) document.head.children.add(_style);
    }

    this._keyframes   = keyframes;
    StringBuffer rule = new StringBuffer('@${Device.cssPrefix}keyframes $_name {');

    keyframes.forEach((percent, properties) {
      rule.write(' $percent%{');
      properties.forEach((name, value) => rule.write('$name:${value.toString()};'));
      rule.write('}');
    });

    rule.write('}');

    this._rule.text = rule.toString();
  }


  /// Modifies a single property for a specific keyframe.
  ///
  /// For a particular [keyframe] the given [property] will
  /// be updated to [value]. If the property does not exist
  /// then it will be created.
  /// The keyframe must exist. If this instance was created
  /// using either of the simpler constructors then the "from"
  /// and "to" keyframes will be 0 and 100 respectively.
  /// This will not affect any elements that are currently
  /// animating with this rule until they have finished.
  ///
  /// Returns false if the keyframe is invalid.
  ///
  bool modify(int keyframe, String property, Object value)
  {
    if (this._keyframes.containsKey(keyframe))
    {
      this._keyframes[keyframe][property] = value;
      this._buildRule(this._keyframes);

      return true;
    }

    return false;
  }


  /// Replaces a set of properties for a specific keyframe.
  ///
  /// For a particular [keyframe] the property map will be
  /// replaced with [properties].
  /// The keyframe must exist. If this instance was created
  /// using either of the simpler constructors then the "from"
  /// and "to" keyframes will be 0 and 100 respectively.
  /// This will not affect any elements that are currently
  /// animating with this rule until they have finished.
  ///
  /// Returns false if the keyframe is invalid.
  ///
  bool replace(int keyframe, Map<String, Object> properties)
  {
    if (this._keyframes.containsKey(keyframe))
    {
      this._keyframes[keyframe] = properties;
      this._buildRule(this._keyframes);

      return true;
    }

    return false;
  }


  /// Removes the rule from the stylesheets.
  ///
  /// To tidy up this removes the rule from the stylesheets, thereby rendering
  /// any future calls to apply() ineffective. Any elements that are currently
  /// animating with this rule will continue to do so.
  ///
  void destroy()
  {
    this._rule.remove();
  }


  /// Apply this animation to an element.
  ///
  /// This animation instance has built and injected a CSS rule into the
  /// stylesheets, therefore it can be applied to as many elements as required.
  /// A number of optional parameters are available which simply pass the
  /// appropriate values through to their CSS counter-parts.
  /// The [duration] of the animation is specified in milliseconds, and the
  /// start of the animation can be [delay]ed by a given number of milliseconds.
  /// If the number of [iterations] is set to zero or a negative value then
  /// the animation will run indefinitely (callback is automatically ignored).
  /// The [alternate] flag will determine whether the animation starts back
  /// at the beginning for each iteration, or if enabled will cause the animation
  /// to bounce back and forth between the start and end keyframes.
  /// Setting the [persist] flag will ensure that when the animation has completed
  /// the styles defined at that point will be applied to the element (since
  /// otherwise these would be lost when the animation property is reset).
  /// The animation [timing] function can be specified from a set of possibilities
  /// defined as constants above. For more information please refer to the relevant
  /// CSS documentation.
  ///
  /// A callback function, [onComplete], if supplied will be invoked when the
  /// animation for this element has completed. However, this parameter will
  /// be ignored if an infinite number of iterations has been specified.
  ///
  /// Note: If you have set a callback and you apply any animation to
  /// this element again before this one has completed then the callback
  /// may not fire and the internal listener may not be removed.
  ///
  void apply(Element element, { int duration:   1000,
                                  int delay:      0,
                                  int iterations: 1,
                                  bool alternate: false,
                                  bool persist:   true,
                                  String timing:  EASE,
                                  CssAnimationComplete onComplete })
  {
    element.style
        ..animationName           = this._name
        ..animationDuration       = '${duration}ms'
        ..animationTimingFunction = timing
        ..animationIterationCount = iterations > 0 ? iterations.toString() : 'infinite'
        ..animationDirection      = alternate ? 'alternate' : 'normal'
        ..animationFillMode       = 'forwards'
        ..animationDelay          = '${delay}ms';

    if (iterations > 0)
    {
      EventListener listener;
      var subscription;

      listener = (AnimationEvent e) {
        if (e.animationName == this._name && e.target == element)
        {
          if (persist)
          {
            var map = (alternate && (iterations % 2) == 0) ? this._keyframes[0] : this._keyframes[100];

            map.forEach((k, v) => element.style.setProperty(k, v.toString()));
          }

          element.style.animation = 'none';
          subscription.cancel();

          if (onComplete != null) onComplete();
        }
      };

      subscription = window.onAnimationEnd.listen(listener);
    }
  }
}