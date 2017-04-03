# EME Extension: HDCP Policy Check

## Motivation

A content license can contain a policy that the CDM must enforce. The ability
of a platform to enforce these policies is a key factor in deciding whether to
begin streaming media and at what quality (resolution and framerate).

HDCP is a common policy requirement for streaming high resolutions of protected
content. Currently, applications can only know if this requirements is met
through key statuses, which are only reported after providing a license. To
provide a license, applications must: generate a license request, post that
request to a license server, wait for the response, provide the response to the
CDM, wait for key status events, and check key statuses.

Application developers would like to know before fetching content if HDCP (and
what version) can be enforced. This would allow the application to start
pre-fetching high resolution content rather than starting at a low resolution or
waiting for the license exchange.

HDCP may be one of many requirements for a content license. The proposed
interface may later be extended to include other requirements as requested by
application developers.

## Overview

The new API will allow application developers to query the status of a
hypothetical key associated with an HDCP policy, without the need to fetch a
real license.

If HDCP is available at the specified version, the promise should return
a MediaKeyStatus of "usable". Otherwise, the promise should return
a MediaKeyStatus of "output-restricted".

A MediaKeyStatus value of "status-pending" must never be returned. Implementers
must give decisive actionable return values for developers to make decisions
about what content to fetch.

```
dictionary MediaKeysPolicyInit {
  DOMString minHdcpVersion = "";
};

[Constructor(optional MediaKeysPolicyInit init), Exposed=Window]
interface MediaKeysPolicy {
  DOMString minHdcpVersion;
}

partial interface MediaKeys {
  Promise<MediaKeyStatus> getStatusForPolicy(MediaKeysPolicy policy);
}
```


## Examples

```js
let hdcpPolicy = new MediaKeysPolicy({minHdcpVersion: "1.0"});

video.mediaKeys.getStatusForPolicy(hdcpPolicy).then(function(status) {
  if (status == 'usable') {
    // Pre-fetch HD content.
  } else {  // such as 'output-restricted' or 'output-downscaled'
    // Pre-fetch SD content.
  }
});
```


## Privacy Considerations

This would allow an application to discover HDCP availability. HDCP is widely
available on most modern operating systems and display types. It is not expected
to add much entropy for fingerprinting.

As access to this API is gated by `requestMediaKeySystemAccess()`, use of this
API may require user consent (e.g., prompt), if required by the user agent for
the configuration. This should make it more difficult to abuse the API on those
user agents.
