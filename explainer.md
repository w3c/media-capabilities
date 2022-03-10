# Media Capabilities explained

This is the explainer for the Media Capabilities API. The document explains the goals and non-goals of the API and in general helps understand the thought process behind the API. The API shape in the document is mostly for information and might not be final.

This document is a bit more dense that some readers might want. A quick one-pager can be found in the [README.md](https://github.com/w3c/media-capabilities/blob/main/README.md) file.

# Objective

The Media Capabilities API enables websites to have a clear view of the abilities that the user agent, the device and the display offer. It provides confidence to the website in the ability of the user agent and device to play a given media. It allows websites to optimise the user’s experience by starting with the best possible content quality.

## Assertions instead of vagueness

The de-facto capability API on the Web Platform today is `canPlayType` which is criticised for being vague. This API has to be clear about what is and is not possible. It should not let the developer try something when it cannot work for obvious reasons: the next action has to be predictable.

## Ability to play is not enough

Another de-facto capability API that was added with the [Media Source Extensions](https://w3c.github.io/media-source/) API (MSE) is `isTypeSupported`. It only returns whether a given format can be played for MSE and clear streams. The ability to decode a media file is a necessary condition for a great media experience. Sadly, it alone is not sufficient.  For example, a mobile browser that supports VP9 decode may not be able to play a 4K VP9 video without dropping many frames, if at all. The user agent has information that can help the website make the right decisions. It should expose relevant information to help the website craft the best experience.

## Output capabilities

In addition to not addressing successful playback, current APIs give no indication of the quality of the experience that reaches the user. For example, whether a 5.1 audio track will be better than (or even as good as) a stereo audio track or whether the display supports a given bit depth, color space, or brightness. When the screen is used to define output capabilities, it is always assumed to be the screen associated with the Window object as defined in the [CSSOM View Module](https://www.w3.org/TR/cssom-view-1/).

## New fundamental layer to the platform

In the spirit of an extensible Web, this API does not intend to make a decision for the website. Instead, its intent is to offer the tools for the website to make the right decisions. Some consumers of this API will have complex use cases and will decide to make different trade offs than others.

As a fundamental platform layer, the intent is for other APIs using capability detection to use this API. For example, the EME capability detection could ideally be defined on top of this one. To be clear, Media Capabilities API cannot and will not replace existing ‘canPlayType’ and ‘isTypeSupported’ because of the contract to be explicit and certain. Media Capabilities API will support new and more granular classifications of media and allow a unified capability detection method. In this respect, the goal is to also allow extensibility for future media format and technology improvements.

A possible future layer would be to allow the user agent, when given a list of formats, to pick the one that will provide the best user experience. This algorithm could be exposed in an API and integrated in the [resource selection algorithm](https://html.spec.whatwg.org/multipage/embedded-content.html#concept-media-load-algorithm) from the HTMLMediaElement. In addition, it is expected that libraries (eg. [Shaka Player](https://github.com/google/shaka-player), [JWPlayer](https://www.jwplayer.com/)) will pick up the signals exposed by the API to make their own decisions.

## Simple and powerful not concise

The API has to be simple and powerful: it should help developers to make the right decision. However, a non-goal is to help the developers to be concise. Answering a simple question with a simple and clear answer is usually not compatible with answering high level questions without making decisions on the browser side. Instead we expect decisions to be made by the API consumer. As a consequence, if a developer wants to know which of the X audio streams can be used with Y video streams, the API will provide them the tools to check this. However, the API will not offer a helper method that does these checks because, as the existence of this API demonstrate, the notion of “compatible” is fuzzy.

# Non goals

## Real time experience management

During the playback, the experience might vary compared to expectations. For example, spiky bandwidth, network switching from wifi to cellular, CPU consuming operation in the background, etc.

Adapting based on the live network capabilities of a device is already common, but there is no API to handle the variation in CPU capability of a device during playback. This API does not intend to solve this problem. [Media Playback Quality](https://wicg.github.io/media-playback-quality/) is being designed to handle this. The two will work together to provide a cohesive whole to developers.

A special case of real time experience is when one page wants to play multiple videos at the same time. It is rare and complex enough to answer a priori that the API might address this in future iterations if it needs to be supported.

## Bandwidth and network information

The Media Capabilities API does not intend to give information to the developers about the capabilities of the device to download a file of a given size or stream at a given bitrate. Other APIs like [Network Information API](https://wicg.github.io/netinfo/) and bandwidth estimation techniques can be used for this.

## Media Capture

The Media Capabilities API does not intend to integrate with the [Media Capture API](https://www.w3.org/TR/media-capture-api/). At the moment, the API is focused on output instead of input. However, re-using concepts when needed would be appropriate. Future iterations of this API could integrate input streams if needed.

# Overview

## Decoding capabilities

The main role of this API is to provide a better solution than `canPlayType` and `isTypeSupported` methods and give clearer, more granular information about the decode abilities of the user agent and the device. To ensure it is able to provide useful information, the API will require some information from the callers in addition of the container MIME type. Both the `video` and the `audio` information will need a MIME type string containing the full codec information. In addition, other information such as `width`, `height`, `bitrate` and `framerate` for `video` and `channels`, `samplerate` and `bitrate` for `audio` will be required.

Based on this data, the API will provide the following information.

**Is this format supported?** (binary - yes/no)

The user agent will be aware that the format as described can’t be played at all. For example, if the user agent is unable to decode AV1 (né VP10), it should simply say so.

**Would this format play smoothly?** The user agent should be able to give an answer regarding the expected observed playback quality. This information can’t be guaranteed because the browser might not be aware of what the user is currently doing outside of the browser or the user bandwidth might also not be able to keep up. Instead, it should be done based on the best of the user agent’s knowledge.

**Would the playback be power efficient?** The user agent has a priori knowledge about the power efficiency of playback and can share this information with the web page. Power efficiency is usually associated with hardware decoding but in practice hardware decoding is just one factor alongside others like resolution. For example, at lower resolutions, software decoded formats are usually power efficient. This is information that the application can combine with the usage of the [Battery Status API](https://w3c.github.io/battery/) to make decisions.

```JavaScript
navigator.mediaCapabilities.decodingInfo({
  type: "file",
  video: {
    contentType: "video/webm; codecs=vp09.00.10.08",
    height: 1080,
    width: 1920,
    framerate: 24,
    bitrate: 2826848,
  },
  audio: {
    contentType: "audio/webm; codecs=opus",
    channels: "2.1",
    samplerate: 44100,
    bitrate: 255236,
  }
}).then(result => {
  console.log(result.supported);
  console.log(result.smooth);
  console.log(result.powerEfficient);
});
```

### Boolean vs floating point for playback smoothness and power efficiency?

The examples in the explainer use a boolean to expose power efficiency and playback smoothness. These values could be floating points to expose confidence or make results relative to each other. The current thinking is that a “confidence” approach would not be interoperable across browsers because each browser will implement their own heuristics. In other words, something that has a 0.7 power efficiency score for UA X might have a 0.8 efficiency score for UA Y. This can lead to compatibility issues with websites requiring an arbitrary power efficiency score based on their tests on a given UA. On the other hand, relative values would allow UA to expose that even if they are not power efficient, one configuration is worse than another.

## Optimising for initial experience

This aim of this API is to help websites provide an optimal initial experience. In other words, allow them to pick the best quality stream the user’s client should be able to handle. In order to do so, other APIs such as the Battery Status API and the [Network Information API](http://wicg.github.io/netinfo/) will be required. As mentioned above, live feedback or capabilities based on the current system load is a non goal.

## Encryption

Playbacks using [Encrypted Media Extensions](https://w3c.github.io/encrypted-media/) (aka EME) employ specialized decoding and rendering code paths. This means different codec support and performance compared to clear playbacks. Hence, callers should describe a key system configuration as part of the `MediaDecodingConfiguration` dictionary.

```Javascript
partial dictionary MediaDecodingConfiguration {
    MediaCapabilitiesKeySystemConfiguration keySystemConfiguration;
};
```

The key system configuration is a dictionary with the following pieces.

```Javascript
dictionary MediaCapabilitiesKeySystemConfiguration {
  required DOMString keySystem;
  DOMString initDataType = "";
  DOMString audioRobustness = "";
  DOMString videoRobustness = "";
  MediaKeysRequirement distinctiveIdentifier = "optional"
  MediaKeysRequirement persistentState = "optional"
  sequence<DOMString> sessionTypes;
};
```

This replicates the inputs provided to EME's [requestMediaKeySystemAccess](https://www.w3.org/TR/encrypted-media/#navigator-extension:-requestmediakeysystemaccess()) `(rMKSA)` with  one major difference: sequences of inputs provided to `rMKSA` are reduced to a single value wherever the intent of the sequence was to have `rMKSA` choose a subset it supports.

Specifically, `rMKSA` takes a sequence of `MediaKeySystemConfigurations`, ordered by preference. Each entry may contain a sequence of initDataTypes and sequences of audio and video contentTypes with robustness. In the dictionary above, all of these sequences are reduced to single values. 

This is a fundamental difference between the APIs. MediaCapabilities aims to describe the quality (smoothness and power efficiency) of support for a single pair of audio and video streams without making a decision for the caller. Callers should still order media configurations as they do with `rMKSA`, only now they walk the list themselves, calling MediaCapabilities once for each option. These calls will return immediately with the promises resolving asynchronously.

When a key system configuration is included in the `MediaDecodingConfiguration`, `mediaCapabilities.decodingInfo()` will return a promise containing the usual three booleans (`supported`, `smooth`, and `powerEfficient`) plus a `MediaKeySystemAccess` object whenever `supported = true`. The caller may use the `MediaKeySystemAccess` as they would in traditional EME to request media keys and setup encrypted media playback. This removes the need to call `rMKSA`.

 Here's a sample usage:

```Javascript
// Like rMSKA(), orderedMediaConfigs is ordered from most -> least wanted.
const capabilitiesPromises = orderedMediaConfigs
    .map(mediaConfig => navigator.mediaCapabilities.decodingInfo(mediaConfig));

(async _ => {
  // Assume this app wants a supported && smooth config.
  let bestConfig = null;
  for await (const mediaCapabilityInfo of capabilitiesPromises) {    
    if (!mediaCapabilityInfo.supported)
      continue;

    if (!mediaCapabilityInfo.smooth)
      continue;

    bestConfig = mediaCapabilityInfo;
    break;
  }

  if (bestConfig) {
    let keys = await bestConfig.keySystemAccess.createMediaKeys();
    // NOT SHOWN: rest of EME path as-is 
  } else {
    console.log('No smooth configs found!');
    
    // NOT SHOWN: More app logic here. Maybe choose the lowest
    // resolution and framerate available.
  }
})();
```



### Permission prompts

EME specifies that a handful of steps in `rMKSA` may request consent from the user. This consent is critical to knowing what encrypted media capabilities are available. Hence, MediaCapabilities will prompt in the same way as `rMKSA`. 

The spec will make clear that calling the API with a key system configuration may result in permission prompts. In practice, such prompts are rare. Currently only Chrome and Mozilla show EME prompts, and Mozilla limits theirs to once per browser profile. 

MediaCapabilities should not show more prompts than `rMKSA`, in spite of requiring more calls to setup encrypted playback. User Agents have a lot of flexibility as to what triggers a prompt and how long the outcome is saved before prompting again. For MediaCapabilities, each implementer should save the outcome at a scoping (e.g. time limited, or session limited) that allows for sufficient reuse between MediaCapabilities calls to avoid spamming the user. 

Additionally, the Permissions API could hypothetically accept the MediaCapabilitiesKeySystemConfiguration dictionary to know when prompts would be shown. 

### Codec and Robustness Compatibility

Media Capabilities should offer a means of surfacing when different MediaDecodingConfigurations are compatible. This is achieved by allowing chained `transtion()` calls to be made on the returned MediaCapabilitiesInfo object. See the [the section below for more on transitions](#transitions).

## HDR

The API is intended to enable high end media playback on the Web as soon as it becomes more mainstream so the platform does not lag behind the curve. This is also a great example of including more formats into the web and keeping the API extensible.

For HDR support detection, there are three main components whose capabilities need to be surfaced -- the decoder, renderer, and screen. The decoder takes in an encoded stream and produces a decoded stream understood by the renderer, which in turn maps the stream's signals to those the screen can properly output. Most of the time, the decoder and renderer are part of the UA while the screen represents the physical output monitor, whether this be a computer monitor or TV. To match this natural modularity between the UA and the screen, this API is compartmentalized into two parts:

*   *MediaCapabilities.decodingInfo()*: handles the UA pieces, namely decoding and rendering. 
*   TODO: various aspects of the screen are being discussed. 

### Screen capabilities

When the UA reports ability to decode HDR content, but the screen does not report ability to render HDR, it is not recommended to transmit HDR content because it wastes bandwidth and may result in actual rendering that is worse than SDR optimized video on some devices.

The shape of this API is actively being discussed, specifically how the two-plane problem in TVs should be handled. Please refer to issue [#135](https://github.com/w3c/media-capabilities/issues/135).

***Work in progress***

### Decode capabilities

HDR content has 3 properties that need to be understood by the decoder and renderer: color gamut, transfer function, and frame metadata if applicable. They can be used to determine whether a UA supports a particular HDR format.

*   Color gamut: HDR content requires a wider color gamut than SDR content. Most UAs support the sRGB color gamut but p3 or Rec. 2020 are color gamut that would usually be expected for HDR content.
*   Transfer function: To map the wider color gamut of HDR content to the screen's signals, the UA needs to understand transfer functions like PQ and HLG.
*   Frame metadata: Certain HDR content might also contain frame metadata. Metadata informs user agents of the required brightness for a given content or the transformation to apply for different values.

Sometimes, all of these are combined in buckets like [HDR10](https://en.wikipedia.org/wiki/HDR10), [HDR10+](https://en.wikipedia.org/wiki/High-dynamic-range_video#HDR10+) [Dolby Vision](https://en.wikipedia.org/wiki/Dolby_Vision) and [HLG](https://en.wikipedia.org/wiki/Hybrid_Log-Gamma). Below are the minimum requirements for frame metadata, color gamut, and transfer respectively for each of the buckets:

*    HDR10: SMPTE-ST-2086 static metadata, Rec. 2020 color space, and PQ transfer function.
*    HDR10+: SMPTE-ST-2094-40 dynamic metadata, Rec. 2020 color space, and PQ transfer function.
*    Dolby Vision: SMPTE-ST-2094-10 dynamic metadata, Rec. 2020 color space, and PQ transfer function.
*    HLG: No metadata, Rec. 2020 color space, and HLG transfer function.

Color gamut, transfer function, and frame metadata -- as they they have to do with decoding and rendering -- are exposed individually on the *MediaCapabilities* interface as part of *VideoConfiguration*, which is queried with *MediaCapabilities.decodingInfo()*.

#### Example

```JavaScript
navigator.mediaCapabilities.decodingInfo({
  video: { 
    // Determine UA support for decoding and rendering HDR10.
    hdrMetadataType: "smpteSt2086",
    colorGamut: "rec2020",
    transferFunction: "pq",
    ...
  }
}).then(result => {
  // Do things based on results. 
  // Note: While some clients are able to map HDR content to SDR screens, check
  // Screen capabilities to ensure high-fidelity playback.
  console.log(result.supported);
  console.log(result.smooth);
  console.log(result.powerEfficient);
  ...
});
```

### Fingerprinting

While exposing HDR capabilities could add many bits of entropy for certain platforms, this API was designed with fingerprinting in mind and does its best to adhere to the Privacy Interest Group's suggested best practices:

1. Avoid unnecessary or severe increases to fingerprinting surface, especially for passive fingerprinting.
*   This API returns only a single boolean per set of input.
2. Narrow the scope and availability of a feature with fingerprinting surface to what is functionally necessary.
*   Various mitigations are suggested in the normative specification.
3. Mark features that contribute to fingerprintability.
*   The normative specification highlights fingerprinting concerns.

## <a name="transitions"></a>Transitioning between stream configurations

The MediaCapabilities `transition()` API will surface when a media element is capable of transitioning between different stream configurations. The primary motivations are:

*  EME's `requestMediaKeySystemAccess` (`rMKSA`) filters an input sequence of codecs+robustness pairs down to a subset that is compatible for use with the returned `MediaKeySystemAccess`. If MediaCapabilities is to stand in for `rMKSA` (see Encryption), it should similarly be able to receive a signal that the developer intends to use multiple codec configurations and be able to surface what combinations are supported how they will perform.

*  vNext features are being incubated for MSE and EME to allow codec/container transitions within a MSE `SourceBuffer`. These address a long standing feature request from streaming sites where advertising may use a different codec or encryption configuration (often clear) from that of the primary content. 

   https://github.com/wolenetz/media-source/blob/codec-switching/codec-switching-explainer.md 
   https://github.com/w3c/encrypted-media/pull/374
   https://github.com/w3c/encrypted-media/issues/251

   To use this feature effectively, developers will need to know up front whether a given codec transition can be supported. Some implementations may not support transitioning between configurations where the transition would require a different decoding pipeline (e.g. HW vs SW).

### Usage
`transition()` is exposed from the `MediaCapabilitiesInfo` object. Callers should first specify an initial stream configuration to `mediaCapabilities.decodingInfo()`, and then pass a secondary `MediaDecodingConfiguration` to the `transition()` API. 

```JavaScript 
// Querying for an initial decoding configuration using VP9
navigator.mediaCapabilities.decodingInfo({
  type: 'media-source',
  video: { contentType: 'video/webm; codecs="vp09.00.10.08"', ...}
}).then(result => {
  if (!result.supported)
      return Promise.reject("Initial configuration unsupported");

  // Initial config supported! Now query for second config using H264
  return info.transition({
    type: 'media-source',
    video: { contentType: 'video/webm; codecs="avc3.64001f"', ... }
  });
}).then(result => {
  if (!result.supported)
    return Promise.reject("Second configuration not supported");

  // Both supported. Inspect the result to see if the *combination* is smooth 
  // and power efficient
  console.log("combined result smooth:%s, powerEffecient:%s", 
              result.smooth, result.powerEfficient);  

  // Not shown: begin playback with the described configuration 
});
```

Note that the input and return types for `transition()` match those from `decodingInfo()`. Both APIs take in a `MediaDecodingConfiguration` and return a promise including a `MediaCapabilitiesInfo` object.

When a `MediaCapabilitiesInfo` object is provided by a `transition()` call, the contents of that object describe the whole chain of decoding configurations observed so far. If any of the configuration is unsupported, the value of supported will be false. Similarly, if any configuration is not smooth or not power efficient, those fields will also be false. 

### Build your own MediaKeySystemAccess
Like the `decodingInfo()` API, `transition()` will also accept a `MediaCapabilitiesKeySystemConfiguration` and the returned `MediaCapabilitiesInfo` will contain a `MediaKeySystemAccess` whenever the configuration is supported.

Each call to `transition()` is a signal that the caller desires to use an additional decoding configuration. Unlike `rMKSA`, the initial MediaCapabilities `decodingInfo()` call does not provide a sequence of codecs+robustness to consider, so it will optimize for whatever has been initially requested. Calling `transition()` will invoke an algorithm to create a new `MediaKeySystemAccess` that can support the new decoding configuration in combination with any configurations provided to the initial `decodingInfo()` or previous chained `trainsion()` calls. 

If no key system can be found to support the combined configurations, the `transition()` promise will resolve with `supported=false` and no `MediaKeySystemAccess` will be provided. 

It may also occur that a supported Key System is available, but the trade off of broader support is worse performance. For example, say the initial `decodingInfo()` call indicated smooth support thanks to a codec-specific HW pipeline. A `transition()` call that specifies a different codec may now report `smooth=false` because only a software pipeline was able to support both configurations. Keep in mind that the `MediaCapabilitiesInfo` object returned from a `transition()` call describes the lowest capabilities across all links in the chain.

Any previously returned `MediaKeySystemAccess` (earlier in the chain) may still be used to setup playback for the configurations it supported. Callers may leverage this if later transition calls are found to be unsupported or if their performance is poor. 

Here's an `transition()` example using a Key System configuration:

```JavaScript
let mediaConfig = {
  'video': {
    'contentType': 'video/webm; codecs="vp09.00.10.08"';
    'width': 1920,
    ...
  },
  // This is MediaCapabilities version: NO sequences here. 
  'keySystemConfig': {
    'keySystem': 'com.widevine.alpha',
    'videoRobustness': 'HW_SECURE_ALL,',
    ...
  }
};

// Check whether the initial mediaConfig (including keySystemConfig) is supported.
mediaCapabilities.decodingInfo(mediaConfig).then( function(vp9CapabilityInfo) {
  // Not shown: optional checks for smooth || powerEfficient.
  if (!vp9CapabilityInfo.supported)
    return Promise.reject('Initial config not supported');

  // MediaKeySystemAccess is provided whenever the encrypted configuration is supported
  console.assert(!!vp9CapabilityInfo.keySystemAccess);

  // Great! Now change the codec and make a chained query to determine if it too is
  // supported by the pipeline associated with the provided capabilityInfo.
  mediaConfig.video.contentType = 'video/mp4; codecs="avc3.42E01E"';
  return vp9CapabilityInfo.transition(mediaConfig);

}).then(function(combinedInfo) {
  // Not shown: optional checks for smooth || powerEfficient. These fields describe the combined   
  // chain based on the lowest performing config. In other words, smooth = true iff all codecs in
  // the chain can be smoothly decoded.
  if (!combinedInfo.supported)
    return Promise.reject('Second config not supported');

  // KeySystemAccess is again provided, now with context that both codecs may be used.
  console.assert(!!combinedInfo.keySystemAccess);

  // Download streams and setup playback!
  let keys = await combinedInfo.keySystemAccess.createMediaKeys();
  
  // NOT SHOWN: rest of EME path as-is 
};
```

### Choosing a pipeline for clear content
Unlike encrypted content, clear playbacks do not have an analog to the MediaKeySystemAccess which can be used to select a pipeline that supports a combination of decoding configurations. In practice, this may not be an issue: implementers have more flexibility when switching between pipelines during clear playback (no keys to worry about). But if needed we could explore choosing clear pipelines by using a MediaCapabilitiesInfo to seed the creation of media elements.

## HDCP support

Now covered in a [separate repository](https://github.com/WICG/hdcp-detection/blob/main/explainer.md).

## Audio channels/speakers configuration

This is already exposed by the Web Audio API [somehow](https://webaudio.github.io/web-audio-api/#ChannelLayouts). If the Web Audio API is not sufficient, the Media Capabilities API might expose this information too. However, the Web Audio API exposes this information on the destination node which is better than what the Media Capabilities API would be able to do.

## Spatial audio

This API aims to enable spatial audio on the Web as increasingly more online content providers serve high-end media playback experiences; examples include [Dolby Atmos](https://en.wikipedia.org/wiki/Dolby_Atmos) and [DST:X](https://en.wikipedia.org/wiki/DTS_(sound_system)#DTS:X). Like [HDR](https://github.com/w3c/media-capabilities/blob/main/explainer.md#hdr), this is an example of web's growth and this API's extensibility.

### Spatial rendering

Spatial rendering describes the UA's ability to to render spatial audio to a given output device; it can be used in conjunction with the stream's mime type to determine support for a specific spatial audio format. 

A Web API exposing spatial rendering is necessary for the following reasons:

*   Because spatial audio is not a codec per se, a client's ability to decode a statial-compatible mime type does not necessitate support for rendering spatial audio.
*   WebAudio's maxChannelCount API cannot be used to discern support for spatial audio, because formats like Dolby Atmos supports two-channel headphones in addition to N-channel speaker systems.
*   Serving content with spatial audio to clients that can decode but not render it results in wasted bandwidth and potentially lower quality user experience.

Spatial rendering is exposed as a boolean included in AudioConfiugration, which can be used to query *MediaCapabilities.decodingInfo()*.

### Example

```JavaScript
navigator.mediaCapabilities.decodingInfo({
  audio: {
    // Determine support for Dolby Atmos by checking Dolby Digital Plus and spatial rendering.
    contentType: "audio/mp4; codecs=ec-3",
    spatialRendering: true,
    ...
  }
}).then(result => {
  // Do things based on results.
  console.log(result.supported);
  console.log(result.smooth);
  console.log(result.powerEfficient);
  ...
});
```

## WebRTC

The API also supports the WebRTC usec case and makes it possible to determine both send and receive capabilities by calling the methods `encodingInfo` and `decodingInfo`. This gives complementary information to what is otherwise received from the methods `RTCRtpSender.getCapabilities` and `RTCRtpReceiver.getCapabilities`. There are a couple of differences to the input to the API when the type `webrtc` is used:

* The contentType should now be a valid media type according to what's defined for RTP. See the examples below and the specification for more details on this.
* An optional field `scalabilityMode` can be used in the video configuration when calling `encodingInfo` to query if a specific scalability mode is supported. See [Scalable Video Coding (SVC) Extension for WebRTC](https://www.w3.org/TR/webrtc-svc/).
* An optional field `spatialScalability` can be used in the video configuration when calling `decodingInfo` to query if the decoder can handle spatial scalability. A bit simplified this can be interpreted as any stream that is encoded with dependent spatial layers according to [Scalable Video Coding (SVC) Extension for WebRTC](https://www.w3.org/TR/webrtc-svc/).

### Examples

#### Decoding info
```JavaScript
navigator.mediaCapabilities.decodingInfo({
  type: 'webrtc',
  video: {
    contentType: 'video/VP9; "profile-id=2"',
    spatialScalability: false,
    height: 1080,
    width: 1920,
    framerate: 24,
    bitrate: 2826848,
  },
  audio: {
    contentType: 'audio/opus',
  }
}).then(result => {
  console.log(result.supported);
  console.log(result.smooth);
  console.log(result.powerEfficient);
});
```

#### Encoding info
```JavaScript
navigator.mediaCapabilities.encodingInfo({
  type: 'webrtc',
  video: {
    contentType: 'video/VP9',
    scalabilityMode: 'L3T3_KEY',
    height: 720,
    width: 1280,
    framerate: 24,
    bitrate: 1216848,
  },
  audio: {
    contentType: 'audio/opus',
  }
}).then(result => {
  console.log(result.supported);
  console.log(result.smooth);
  console.log(result.powerEfficient);
});
```

# Privacy Considerations

The Media Capabilities API will provide a lot of information to enable websites to optimise the user experience. None of this is sensitive information about the user. However, some of the data being exposed could be used to fingerprint users or track them across websites.

## Decoding capabilities and class of devices

Most of the information exposed by the media capabilities will provide very little entropy for fingerprinting because they will have a high correlation with other device information that are likely already leaked. Especially for mobile devices, as given phone/tablet or even laptop will be able to decode the same media streams with the same ability. A given model, and even more likely, a class of models (high end 2015 for example) will all have the some hardware decoding abilities and similar CPUs offering comparable software decoding capabilities. For desktops, because the hardware is more diverse, it is unclear how much entropy will be added.

Implementations that measure or benchmark performance should take extra care to avoid exposing entropy (i.e unique values). For example, exposing very precise and/or unique resolutions, bitrates, or smoothness and power efficiency values.

## Hardware setup

The HDR screen ability, HDCP and channels/speakers set up could expose more fingerprinting entropy. As with decoding capabilities, HDR and HDCP will be mostly the same for a given class of mobile devices unless they are using an external monitor. Unless they are considered serious fingerprinting issues (and thus need to be explicitly addressed), the specification will provide fallback for implementations that want to tie these information to a permission or an option that will block their access.

## Expose permission information

Exposing permission status is mostly harmless because it is already fairly easy for a website to discover the status of a permission. This is also exposed in the Permissions API in the `query()` method, which is shipped in Firefox and Chrome.

There might be a concern specifically about exposing permission information for EME: a website might be able to guess if EME was disabled by the user or if the user is running a browser that doesn’t support EME because the permission could be granted while EME wouldn’t be allowed.

# Examples

## Discover capabilities for DASH Manifest

Some examples of DASH Manifest:

*   https://github.com/Axinom/dash-test-vectors
*   http://dash-mse-test.appspot.com/media.html

This is assuming that the DASH Manifest does not use encrypted content.

A DASH Manifest contains a list of `AdaptationSet` which represent a media stream like a video or audio. DASH manifest usually separate their audio and video streams in different `AdaptationSet`. Inside an AdaptationSet, there is one or more `Representation`. Each of them is a representation of the stream (i.e. the `AdaptationSet`).

An implementation could build a list of `Representation` for a given `AdaptationSet` and use the API to discover the ability of the device for the each representation. The example below assumes that `representations` is an array of `Element` that represents the XML element from the DASH Manifest and the implementation will filter out the entry that are not playable (`contentType` is `video`).

```JavaScript
function triageVideoRepresentations(representations) {
  var capabilitiesRequests = [];
  representations.forEach(representation => {
    capabilitiesRequests.append(navigator.mediaCapabilities.decodingInfo({
      video: {
        contentType: representation.getAttribute('mimeType') + '; ' + representation.getAttribute('codecs'),
        bitrate: representation.getAttribute('bandwidth'),
        height: representations.getAttribute('height'),
        width: representations.getAttribute('width'),
        framerate: representations.getAttribute('frameRate')
      },
    }));
  });

  return Promise.all(capabilitiesRequests).then(results => {
    // This is assuming `representations` can still be accessed.
    var filteredRepresentations = [];
    for (var i = 0; i < representations; ++i) {
      if (results.supported && results.smooth)
        filteredRepresentations.append(representations[i]);
    }
    return filteredRepresentations;
  });
}
```
