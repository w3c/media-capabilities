# Media Capabilities explained

This is the explainer for the Media Capabilities API. The document explains the goals and non-goals of the API and in general helps understand the thought process behind the API. The API shape in the document is mostly for information and might not be final.

This document is a bit more dense that some readers might want. A quick one-pager can be found in the [README.md](https://github.com/WICG/media-capabilities/blob/master/README.md) file.

# Objective

The Media Capabilities API enables websites to have a clear view of the abilities that the user agent, the device and the display offer. It provides confidence to the website in the ability of the user agent and device to play a given media. It allows websites to optimise the user’s experience by starting with the best possible content quality.

## Assertions instead of vagueness

The de-facto capability API on the Web Platform today is `canPlayType` which is criticised for being vague. This API has to be clear about what is and is not possible. It should not let the developer try something when it cannot work for obvious reasons: the next action has to be predictable.

## Ability to play is not enough

Another de-facto capability API that was added with the [Media Source Extensions](https://w3c.github.io/media-source/) API (MSE) is `isTypeSupported`. It only returns whether a given format can be played for MSE and clear streams. The ability to decode a media file is a necessary condition for a great media experience. Sadly, it alone is not sufficient.  For example, a mobile browser that supports VP9 decode may not be able to play a 4K VP9 video without dropping many frames, if at all. The user agent has information that can help the website make the right decisions. It should expose relevant information to help the website craft the best experience.

## Output capabilities

In addition to not addressing successful playback, current APIs give no indication of the quality of the experience that reaches the user. For example, whether a 5.1 audio track will be better than (or even as good as) a stereo audio track or whether the display supports a given bit depth, color space, or brightness. When the screen is used to define output capabilities, it is always assumed to be the screen associated with the Window object as defined in the [CSSOM View Module](https://www.w3.org/TR/cssom-view-1/).

## New fundamental layer to the platform

In the spirit of an extensible Web, this API is not intendeddoes not intend to make a decision for the website. Instead, its intent is to offer the tools for the website to make the right decisions. Some consumers of this API will have complex use cases and will decide to make different trade offs than others.

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

The Media Capabilities API does not intend to give information to the developers about the capabilities of the device to download a file of a given size or stream at a given bitrate. Other APIs like [Network Information API](https://wicg.github.io/netinfo/) and bandwidth estimations techniques can be used for this.

## Media Capture

The Media Capabilities API does not intend to integrate with the [Media Capture API](https://www.w3.org/TR/media-capture-api/). At the moment, the API is focused on output instead of input. However, re-using concepts when needed would be appropriate. Future iterations of this API could integrate input streams if needed.

# Overview

## Decoding capabilities

The main role of this API is to provide a better solution than `canPlayType` and `isTypeSupported` methods and give clearer, more granular information about the decode abilities of the user agent and the device. To ensure it is able to provide useful information, the API will require some information from the callers in addition of the container MIME type. Both the `video` and the `audio` information will need a MIME type string containing the full codec information. In addition, other information such as `width`, `height`, `bitrate` and `framerate` for `video and `channels`, `samplerate` and `bitrate` for `audio` will be required.

Based on this data, the API will provide the following information.

**Is this format supported?** (binary - yes/no)

The user agent will be aware that the format as described can’t be played at all. For example, if the user agent is unable to decode AV1 (né VP10), it should simply say so.

**Would this format play smoothly?** The user agent should be able to give an answer regarding the expected observed playback quality. This information can’t be guaranteed because the browser might not be aware of what the user is currently doing outside of the browser or the user bandwidth might also not be able to keep up. Instead, it should be done based on the best of the user agent’s knowledge.

**Would the playback be power efficient?** The user agent has a priori knowledge about the power efficiency of playback and can share this information with the web page. Power efficiency is usually associated with hardware decoding but in practice hardware decoding is just one factor alongside others like resolution. For example, at lowerresolutions, software decoded formats are usually power efficient. This is information that the application can combine with the usage of the [Battery Status API](https://w3c.github.io/battery/) [t](https://w3c.github.io/battery/)o[ ](https://w3c.github.io/battery/)m[a](https://w3c.github.io/battery/)k[e](https://w3c.github.io/battery/) [d](https://w3c.github.io/battery/)e[c](https://w3c.github.io/battery/)i[s](https://w3c.github.io/battery/)i[o](https://w3c.github.io/battery/)n[s](https://w3c.github.io/battery/).

```
navigator.mediaCapabilities.query({
  type: "file",
  video: {
    type: "video/webm codec=vp9.0",
    height: 1080,
    width: 1920,
    framerate: 24,
    bitrate: 2826848,
  },
  audio: {
    type: "audio/webm codec=opus",
    channels: "2.1",
    samplerate: 44100,
    bitrate: 255236,
  }
}).then(result => {
  console.log(result.isSupported);
  console.log(result.isSmoothPlayback);
  console.log(result.isPowerEfficient);
});
```

### Boolean vs floating point for playback smoothness and power efficiency?

The examples in the explainer use a boolean to expose power efficiency and playback smoothness. These values could be floating points to expose confidence or make results relative to each other. The current thinking is that a “confidence” approach would not be interoperable across browsers because each browser will implement their own heuristics. In other words, something that has a 0.7 power efficiency score for UA X might have a 0.8 efficiency score for UA Y. This can lead to compatibility issues with websites requiring an arbitrary power efficiency score based on their tests on a given UA. On the other hand, relative values would allow UA to expose that even if they are not power efficient, one configuration is worse than another.

## Optimising for initial experience

This aim of this API isaims to help websites provide an optimal initial experience. In other words, allow them to pick the best quality stream the user’s client should be able to handle. In order to do so, other APIs such as the Battery Status API and the [Network Information API](http://wicg.github.io/netinfo/) will be required. As mentioned above, live feedback or capabilities based on the current system load is a non goal.

## Encryption

The [Encrypted Media Extension](https://w3c.github.io/encrypted-media/) (aka EME) implements its own capability functionality. Decryption (DRM) adds specific restrictions to the playback: a supported Key System might not be available, some might not play media formats that can otherwise be played by the user agent, some level of robustness might not be available, etc.

The EME capability detection is the most advanced currently in the Web Platform but is specific to encrypted content so can not be used for general capability detection. 

The approach taken by the Media Capabilities API is to define an API at a lower level. The Media Capabilities API could be used to describe the EME capabilities detection apart from the permission requesting. This means that the Media Capabilities API will lack the user friendliness that [requestMediaSystemAccess](https://w3c.github.io/encrypted-media/#dom-navigator-requestmediakeysystemaccess) has.

Finally, the Media Capabilities API will not return a [MediaKeySystemAccess](https://w3c.github.io/encrypted-media/#idl-def-mediakeysystemaccess) object. Authors using EME will have to ultimately call [requestMediaSystemAccess](https://w3c.github.io/encrypted-media/#dom-navigator-requestmediakeysystemaccess) in order to get the MediaKeys object and obtain keys.

```
// Check support and performance.
navigator.mediaCapabilities.query({
  type: 'MediaSource',
  video: { type: "video/webm codec=vp9.0", width: 1280, height: 720,
           framerate: 24, bitrate: … },
  audio: { type: "audio/webm codec=opus" },
  encryption: { robustness: { audio: "bar", video: "foo" },
                keySystem: "org.w3.clearkey",
                initDataType: "keyids",
                persistentState: "required",
                sessionTypes: [ "temporarypersistent-usage-record",
                                "persistent-license" ],
  },
}).then(result => {
  // If the key system isn't supported, the key system doesn't support the
  // codecs, or there is any other issue, isSupported will be false.
  if (!result.isSupported || !result.isSmoothPlayback)
    throw Error("Don't play this");

  // This call is only meant to get a MediaSystemAccess object.
  return navigator.requestMediaKeySystemAccess("org.w3.clearkey", [)
    audioCapabilities: [ { contentType: "video/webm codec=opus",
                           robustness: "bar" } ],
    videoCapabilities: [ { contentType: "video/webm codec=vp9.0",
                           robustness: "foo" } ],
    initDataTypes: [ "keyids" ],
    persistentState: "required",
    sessionTypes: [ "temporarypersistent-usage-record",
                    "persistent-license" ],
  }]);
}).catch{_ = {
  // Try another format/key system/robustness combination.
});
```

### Permissions

The EME API is designed to be able to prompt the user if needed. The reasons is that the DRM systems might require some “super cookie” to identify the device or, for example, with Firefox, the browser might need to download the components on-demand.

It makes a querying API such as Media Capabilities more complex because the capabilities of the device might actually depend on the action the user takes on the requestMediaKeySystemAccess’ permission prompt. The following are proposals to solve this problem.

#### Prompt from Media Capabilities calls

One solution is for the Media Capabilities API to check and request consent (i.e. prompt) when the `encryption` member is present and user consent is required. The returned capabilities will depend on the user decision. The downsides of this approach is that it might be surprising for developers because the API is otherwise never prompting. In addition, it is possible that the user dismisses the Media Capabilities API prompt in which case the API will have to expose the permission as not granted but could not guarantee that a call to `requestMediaKeySystemAccess` would provide the same result.

#### Expose request status in Media Capabilities response

This approach will not prompt but instead will provide a boolean exposing if a call to `requestMediaKeySystemAccess` will require a prompt. It will allow the developers to implement their flow based on this information. It resolves the uncertainty of getting different results from Media Capabilities and EME. However, the Media Capabilities response will depend on the prompt result. The Media Capabilities results will have to either expose the results if the permission is granted, denied or not expose results in this situation. Exposing results based on the permission being denied is probably the most conservative and privacy aware solution because the developer will not build an experience that might be broken if the prompt is rejected and can instead be ready for the worse case scenario.

#### Building on top of the Permissions API

This solution is very similar to the previous one but instead of exposing the permission status in the Media Capabilities, it is re-using other components of the Web Platform. With this approach, the developer would have to query the Permissions API for the permissions status and the Media Capabilities API for the capabilities. The capabilities will matching the current permission status. As above, the capabilities should probably expose the not granted results if the permission status is set to `prompt`. In addition of re-using other APIs, this approach could also use the work in progress `request` method of the Permissions API which will allow the developers to request permission for a specific EME configuration before making a call to the `requestMediaKeySystemAccess`.

## HDR

HDR support in browsers is nonexistent. The API is intendedintends to enable high end media playback on the Web as soon as it becomes more mainstream so the platform does not lag behind the curve. This is also a great example of including more formats into the web and keeping the API extensible. 

### Screen capabilities

Even if a device is able to decode HDR content, if the screen isn’t able to show this content appropriately, it might not be worth using HDR content for the website because of the higher bandwidth consumptions but also the rendering might be worse than a SDR optimised video.

The following data can be used to define whether a screen is HDR-worthy:

*   Colour gamut: HDR content requires a wider colour gamut than SDR content. Most screens use the sRGB colour gamut but p3 or BT.2020 are colour gamut that would usually be expected for HDR content.
*   Colour/pixel depth: even if the screen has a wide colour gamut, the pixels need to be encoded in 30 bits (10 bits per colour component) instead of the usual 24 bits (8 bits per colour component). Otherwise, even if wider colour can be represented, precision would be lost.
*   Brightness: because of darker blacks and brighter whites, a screen needs to have a large contrast ratio in order to be used for HDR content.

#### Colour gamut

The colour gamut of the screen could be exposed on the *Screen* interface. It is already part of the work in progress [CSS Media Queries 4](https://drafts.csswg.org/mediaqueries-4/#color-gamut) but because various information will have to be read from the *Screen* object for HDR content, it would make sense to have all of them grouped together.

#### Colour/Pixel Depth

It is already exposed on the *Screen* object but only for compatibility reasons. The [CSSOM View Module](https://www.w3.org/TR/cssom-view-1/#dom-screen-pixeldepth) should be updated or amended to make this information available.

#### Brightness

The minimum and maximum brightness should be exposed on the *Screen* object. In order to know the effective brightness, a website would need to know the brightness of the room which can be achieved with the [Ambient Light Sensor](https://w3c.github.io/ambient-light/).

#### Example

```
function canDisplayMyHDRStreams() {
  // The conditions below are entirely made up :)
  return window.screen.colorGamut == "rec2020" && 
         window.screen.pixelDepth == "30" &&
         window.screen.brightness.max > 500 &&
         window.screen.brightness.min < 0.1;
}
```

### Screen change

The Web Platform only exposes the current screen associated to the website window. That means that a window changing screen will get its `window.screen` updated. A page can poll to find out about this but adding a *change* event to the *Screen* interface might be a more efficient way to expose this information.

### Decode capabilities

HDR videos have some information that need to be understood by the user agent in order to be rendered correctly. A website might want to check that the user agent will be able to interpret its HDR content before providing it.

HDR content has 4 properties that need to be understood by the decoder: primaries, yuv-to-rgb conversion matrix, transfer function and range. In addition, certain HDR content might also contain frame metadata. Metadata informs user agents of the required brightness for a given content or the transformation to apply for different values. Sometimes, all of these are combined in buckets like [HDR10](https://en.wikipedia.org/wiki/HDR10), [Dolby Vision](https://en.wikipedia.org/wiki/Dolby_Vision) and [HLG](https://en.wikipedia.org/wiki/Hybrid_Log-Gamma).

**Work in progress**

At this point, it is unclear what should be exposed in this API: HDR frame metadata formats are not yet standardised, and it remains unclear if other properties should be exposed granularly or in buckets. The first iteration of this specification will not include HDR decoding capabilities until it receives implementer feedback. This is currently slated for $todo.

At the moment, no operating system besides Android exposes HDR capabilities. Android exposes HDR capabilities using the buckets mentioned above. See [HdrCapabilities](https://developer.android.com/reference/android/view/Display.HdrCapabilities.html) interface and the [HDR Types](https://developer.android.com/reference/android/view/Display.HdrCapabilities.html#getSupportedHdrTypes()).

Regardless of what is exposed, the HDR information will be part of an *hdr* sub-dictionary as part of the *video* information.

```
navigator.mediaCapabilities.query({
  Type: 'file',
  video: { type: "video/webm codec=vp9.0", width: 1280, height: 720,
           framerate: 24, bitrate: `… ,
           hdr: { ... } },
  audio: { type: "audio/webm codec=opus" },
});
```

## Adaptive playback and transitions

Transitioning between states, either between encrypted and clear playback or between different formats during adaptive playback can change the playback quality either because of implementation bugs or limitations. There are four types of transition issues:

**Switching from encrypted to clear playback:** Chrome fails to do such transition, see [bug](https://crbug.com/597443). In this case, content will have to either have two different players and switch (the transition will unlikely be smooth) or the playback will stop. This happens for encrypted content streaming that has clear playback interstitials like ads.

**Switching from one video codec to another:** Browsers are usually not able to change codecs during adaptive playback. Media Source Extension v1 does not allow seamless codec transition and allows but does not require codec transitions using different tracks. As above, a common use case is interstitials that might be in a different codec than the main content.

**Switching from hardware to software playback:** Some browsers can’t switch out of their hardware playback pipeline such as if the adaptive playback goes to a resolution that can’t be played using the pipeline, the playback will fail. A player that attempts to play at low resolution and increase the quality might hit such bugs in implementations where the hardware decoding can’t handle more than 1080p.

**Switching from software to hardware playback:** Some browsers will not switch back to hardware playback when the playback has already started on the software pipeline. In such situations the playback information returned for playing two different formats will not be the same as playing one then switching to the other.

Exposing the ability to transition would allow website to make better decisions with regards to which codec to use and which format to start playback with. Most of the limitations are currently well known and websites already assume that transitioning codecs during an adaptive streaming using the same source buffer is not possible. In other words, most of the quality of implementation problems are mostly accounted for by websites and exposing an API to discover them would not dramatically impact websites unless user agents start fixing these bugs at the same time.

However, exposing transition capabilities would allow websites to understand and take into account some implementation decisions made by websites. For example, the software to hardware transition might come with a surprise to a website that tries to go above the hardware pipeline limit and when going back does not achieve the same performance.

Furthermore, exposing transition abilities will help toward the goal of expressing other media API with this API. The *requestMediaKeySystemAccess* method in EME handles capability combinations; with support for transition capability detection, it could be expressed fully with the Media Capabilities API with the exception of the permission handling.

Therefore, exposing transition capabilities is considered part of the specification but will not be one of the first priorities because of its limited use cases. This could be revisited if web authors express interest.

### Why not a list of formats?

An approach taken by the EME API and that might sound natural is to expose the ability to transition from multiple formats inside a list. The EME API does something a bit more sophisticated and will start with the first working configuration and will append to the returned lists all the format transitions that are possible.

The downsides of this approach is that it does not offer a clear view of the consequences of transitioning: one can transition from A to B but it does not mean that the playback of A and B will be of the same quality (isSmoothPlayback and isPowerEfficient). Also, in the case of the EME approach, picking the first working configuration would be against the principles of making decisions for the website because a configuration might be playable but not ideal and the user agent would have to decide whether to start with this one or another one.

### Examples

Without exposing transition capabilities, in order for a website to check if a list of formats are supported, the best approach is the following:

```
function canAdapt(formats) {
  var capabilities = [];
  formats.forEach(entry => capabilities.push_back(navigator.mediaCapabilities.query(entry)));
  return Promise.all(capabilities).then(results => {
    bool supported = true;
    results.forEach(r => { if (!r.isSupported) supported = false; });
    return supported;
  });
}
```

With a transition capabilities, a website no longer need to assume that supports of {A, B} means ability to transition from A to B and B to A with the same capabilities as playing A or B independently.

```
navigator.mediaCapabilities.query({
  type: 'MediaSource',
  video: { type: "video/webm codec=vp9.0", width: 1280, height: 720,
           framerate: 24, bitrate: … },
  audio: { type: "audio/webm codec=opus" }
}).then(result => {
  console.log(result.isSupported);
  console.log(result.isSmoothPlayback);
  console.log(result.isPowerEfficient);
  return result.transition({
    type: 'MediaSource',
    video: { type: "video/webm codec=vp10", width: 1280, height: 720,
             framerate: 24, bitrate: … },
    audio: { type: "audio/webm codec=opus" }});
}).then(result => {
  // isSupported is specific to vp9 to vp10 transition here.
  // If vp10 isn't supported, it will never be true but if vp10 is supported
  // it does not mean it will be true.
  console.log(result.isSupported);
  console.log(result.isSmoothPlayback);
  console.log(result.isPowerEfficient);
});;

// Here we assume than vp9 and vp10 are using a different pipeline.
navigator.mediaCapabilities.query({
  type: 'MediaSource',
  video: { type: "video/webm codec=vp10", width: 1280, height: 720,
           framerate: 24,  bitrate: … },
  audio: { type: "audio/webm codec=opus" }
}).then(result => {
  // result.isSupported == true;
});

navigator.mediaCapabilities.query({
  type: 'MediaSource',
  video: { type: "video/webm codec=vp9.0", width: 1280, height: 720,
           framerate: 24, bitrate: … },
  audio: { type: "audio/webm codec=opus" }
}).then(result => {
  // result.isSupported == true;
  return result.transition({
    type: 'MediaSource',
    video: { type: "video/webm codec=vp10", width: 1280, height: 720,
             framerate: 24, bitrate: …  },
    audio: { type: "audio/webm codec=opus" }});
}).then(result => {
  // result.isSupported == false;
});;
```

However, transitions are not symmetric, the capabilities of a transition from A to B are not similar to the capabilities to transition from B to A.

```
// Here we assume than vp9 and vp10 are using a different pipeline.
navigator.mediaCapabilities.query({
  type: 'MediaSource',
  video: { type: "video/webm codec=vp10", width: 1280, height: 720,
           framerate: 24, bitrate: … },
  audio: { type: "audio/webm codec=opus" }
}).then(result => {
  // result.isSupported == true;
  // result.isPowerEfficient == true;
});

navigator.mediaCapabilities.query({
  type: 'MediaSource',
  video: { type: "video/webm codec=vp9.0", width: 1280, height: 720,
           framerate: 24, bitrate: … },
  audio: { type: "audio/webm codec=opus" }
}).then(result => {
  // result.isSupported == true;
  // result.isPowerEfficient == false;
  return result.transition({
    type: 'MediaSource',
    video: { type: "video/webm codec=vp10", width: 1280, height: 720,
             framerate: 24, bitrate: … },
    audio: { type: "audio/webm codec=opus" }});
}).then(result => {
  // result.isSupported == true;
  // result.isPowerEfficient == false;
});;
```

## HDCP support

Content providers might have requirements to only show some content if HDCP is enabled. HDCP support could be bundled into the EME API or added as part of the *encryption* dictionary in the Media Capabilities API. However, both approach will allow websites to find out if HDCP is enabled without having a direct access to the information.

Another, more straightforward, approach is to expose HDCP on the `Screen` object as an asynchronous property. The returned Promise could expose the supported HDCP level if any or reject if the information is not available.

```
window.screen.hdcp.then(value => {
  If (value.startsWith(`2.')
    Hdcp2IsSupported();
});
```

## Audio channels/speakers configuration

This is already exposed by the Web Audio API [somehow](https://webaudio.github.io/web-audio-api/#ChannelLayouts). If the Web Audio API is not sufficient, the Media Capabilities API might expose this information too. However, the Web Audio API exposes this information on the destination node which is better than what the Media Capabilities API would be able to do.

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

```
function triageVideoRepresentations(representations) {
  var capabilitiesRequests = [];
  representations.forEach(representation => {
    capabilitiesRequests.append(navigator.mediaCapabilities.query({
      video: {
        type: representation.getAttribute('mimeType') + '; ' + representation.getAttribute('codecs'),
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
      if (results.isSupported && results.isSmoothPlayback)
        filteredRepresentations.append(representations[i]);
    }
    return filteredRepresentations;
  });
}
```
