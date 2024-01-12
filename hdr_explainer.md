# HDR Capability Detection

HDR capabilities are detected with a combination of CSS and MediaCapabilities APIs.  Both APIs should be called to determine if HDR can be correctly presented.

Please note that both of these APIs are fairly new and are not yet implemented by all user agents. See Implementations section below.

# CSS: is the display HDR capable?

Media Queries Level 5 defines a `dynamic-range` feature, with values `"standard"`  and `"high"`.

https://www.w3.org/TR/mediaqueries-5/#descdef-media-dynamic-range

```
let isScreenHDR = window.matchMedia('(dynamic-range: high)').matches;
```

This indicates whether the current display is HDR capable.

# CSS: video-* prefixed MediaQueries

User agents on TVs tend to offer video capabilities at the native resolution and dynamic range (ex: 4k HDR) while offering much lower capabilities for the rest of the web page (maybe 1080p SDR). To surface these distinct capabilities, Media Queries Level 5 defines features prefixed by "video-".

https://www.w3.org/TR/mediaqueries-5/#video-prefixed-features

This includes `video-dynamic-range`. On televisions, this value may be `"high"` while the non-prefixed `dynamic-range` remains `"standard"`.

On desktop and mobile devices, values for video-* features will generally match their non-prefixed counterparts.

The sizing video-* prefixed features are still under discussion, see CSS issues [#4471](https://github.com/w3c/csswg-drafts/issues/4471), [#4678](https://github.com/w3c/csswg-drafts/pull/4678), [#5044](https://github.com/w3c/csswg-drafts/issues/5044), and [#6891](https://github.com/w3c/csswg-drafts/issues/6891). Rather than add `video-width`, `video-height`, and `video-resolution` media queries, the current proposal is to expose a `deviceVideoPixelRatio` property.

# MediaCapabilities: does the UA support decoding/rendering my brand of HDR video?

Use MediaCapabilities to ask about HDR video decoding/rendering capabilities, **independent of the display capabilities**.
* Does it support the desired transfer function? https://www.w3.org/TR/media-capabilities/#transferfunction
* Does it support rendering in the desired color gamut? https://www.w3.org/TR/media-capabilities/#colorgamut
* Does it support the desired HDR metadata? https://www.w3.org/TR/media-capabilities/#hdrmetadatatype

Here's a code sample (note the last 3 fields in `hdrConfig`).
```
let hdrConfig = {
  type: 'media-source',
  video: {
    contentType: 'video/webm; codecs="vp09.00.10.08"',
    width: 1920,
    height: 1080,
    bitrate: 2646242,
    framerate: '25',
    transferFunction: 'pq',
    colorGamut: 'p3',
    hdrMetadataType: 'smpteSt2086',
  }
};

navigator.mediaCapabilities.decodingInfo(hdrConfig).then(function(info) {
	if (info.supported) {
		// Playback is supported! See also, info.smooth and info.powerEfficient.
	}
});
```

# Implementations

As of 2020/21, here's the unofficial status of user agent implementations for the above:
* CSS dynamic-range is implemented by Safari. Not yet started by Chrome (ETA early 2021), nor Firefox
* CSS video-* features are not yet implemented anywhere.
* MediaCapabilities HDR inputs are implemented by Safari. Chrome's implementation is work-in-progress. Not yet started in Firefox.
