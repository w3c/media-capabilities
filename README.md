# Media Capabilities API

## Problem Statement

To deliver media across an enormous range of devices and networks, modern services stream their content in a wide range of formats - varying by codec, resolution, container format, encryption scheme, and other dimensions.  Unlike many devices, browsers run across a wide range of platforms and hardware, so identifying which formats are optimal - or even supported - is challenging.  Existing Web APIs, like [isTypeSupported](https://www.w3.org/TR/media-source/#dom-mediasource-istypesupported) and [canPlayType](https://www.w3.org/TR/html5/embedded-content-0.html#dom-navigator-canplaytype) are vague and insufficiently expressive; thus sites often pick an arbitrary target independent of actual capabilities.

## Main Requirements

The Media Capabilities API seeks to provide definitive answers on several playback dimensions:

*   Given its properties, can a specified piece of media content be played at all?
*   Will playback have high quality (smoothness)?  Will it be power efficient?
*   Do output capabilities (e.g. color gamut, dynamic range, audio channels) match content?
*   Are security requirements (e.g. encryption, HDCP, etc) supported or playback-impacting?
*   Given multiple possible media formats, which is preferable?

The sum of these requirements is simple; given the reality that content items are stored in multiple formats and levels, which of these should be selected for delivery to a particular UA?

## Solution Outline

The proposed solution is to introduce a new API and corresponding set of properties that meet the requirements above:

*   A new query-based capability API allows pages to identify whether a given combination of properties - codec and profile, resolution, frame/sample rate, bit rate, bit depth, pixel format, color space, EOTF, content protection scheme, and others - is supported.  If so, estimates of playback quality and power efficiency will also be provided.  This mostly corresponds to the decoding capability of the UA.

*   Additional output properties (e.g. on window.screen), such as color gamut and dynamic range, will identify what can meaningfully be rendered to the user.  This helps sites avoid resource-intensive formats that can be decoded but not properly displayed (e.g. HDR content on a SDR display, or multichannel audio with stereo speakers).

*   Even with the above, existing APIs and heuristics remain important.  Network and CDN throughput aren’t addressed by the above but often constrain viable bitrates.  Real-time contention for CPU/GPU, detected using dropped frame count or perhaps the new [Media Playback Quality](https://wicg.github.io/media-playback-quality/) API, may also dynamically limit quality (e.g. forcing lower resolution).

The above allows sites to make optimal decisions, most of the time, before streaming begins.
