# Media Capabilities - Security and Privacy Questionnaire

This document answers the [W3C Security and Privacy
Questionnaire](https://w3ctag.github.io/security-questionnaire/) for the
Media Capabilities specification.

Last Update: 2020-01-30

**What information might this feature expose to Web sites or other parties, and
for what purposes is that exposure necessary?**

The API exposes information about the support, performance (smoothness), and
power efficiency of various media configurations.

Example query: Can you decode 4k AV1 as part of a media-source playback?
Example answer: Yes, but it will not play smoothly and it will not be power
efficient.

This information is used by sites to select optimal media configurations. Sites
will often have multiple configurations to choose from for a given stream and
will weigh trade-offs like bandwidth savings offered by the latest codecs
against their performance and power efficiency.

**Do features in your specification expose the minimum amount of information
necessary to enable their intended uses?**

Yes. The API aims to answer the important questions without providing any
extraneous detail (e.g. we make a simple performance prediction without offering
a confidence interval).

**How do the features in your specification deal with personal information,
personally-identifiable information (PII), or information derived from them?**

This specification does not deal with PII.

**How do the features in your specification deal with sensitive information?**

This specification does not deal with sensitive information.

**Do the features in your specification introduce new state for an origin that
persists across browsing sessions?**

No.

**Do the features in your specification expose information about the underlying
platform to origins?**

Yes. Information about codec support, performance and power efficiency is
implicitly describing the underlying platform. The information is not
origin-specific.

The specification describes the predictions about performance and
powerEfficiency, but does not prescribe how the UA makes those predictions, nor
how often the UA should update the predicted values. Acceptable solutions
include updating the data continuously, at every browser reboot, or even never
(the UA may hard code it's answers).


**Do features in this specification allow an origin access to sensors on a
user’s device?**

No.

**What data do the features in this specification expose to an origin? Please
also document what data is identical to data exposed by other features, in the
same or different contexts.**

3 booleans indicating codec support, performance (smoothness), and
power efficiency.

The question of support can also be answered by older APIs. Examples include
HTMLMediaElement.canPlayType(), MediaSource.isTypeSupported(),
MediaRecorder.isTypeSupported(), and RTCRtpReceiver.getCapabilities().

Performance (smoothness) predictions are unique to this API. Though it is
possible to observe real-time performance statistics via other APIs. Examples
include HTMLMediaElement.getVideoPlaybackQuality() and
RTCPeerConnection.getStats().

Power efficiency predictions are mostly unique to this API. A configuration is
considered "power efficient" when it is hardware accelerated or when its
complexity (e.g. resolution) is sufficiently low such that a software codec
would use a similar amount of power to a hardware accelerated alternative.
For WebRTC, real-time hardware acceleration information is available via the
RTCPeerConnection.getStats() API (decoderImplementation == "ExternalDecoder") on
some UAs (at least Chromium).


**Do features in this specification enable new script execution/loading
mechanisms?**

No.


**Do features in this specification allow an origin to access other devices?**

No.


**Do features in this specification allow an origin some measure of control over
 a user agent’s native UI?**

No.


**What temporary identifiers do the features in this specification create or
expose to the web?**

None.


**How does this specification distinguish between behavior in first-party and
third-party contexts?**

It does not distinguish.

**How do the features in this specification work in the context of a browser’s
Private Browsing or Incognito mode?**

The specification does not prescribe a specific behavior for these modes. The
specified features do not inherently allow for detection such modes, nor do they
leak information between modes.

**Does this specification have both "Security Considerations" and "Privacy
Considerations" sections?**

It has a [combined section on Security and Privacy](https://w3c.github.io/media-capabilities/#security-privacy-considerations), 
mostly focused on Privacy. There are no known security impacts of the features in this specification.

**Do features in your specification enable downgrading default security
characteristics?**

No.
