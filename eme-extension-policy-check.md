# EME Extension: Policy Check

## Motivation

A content license can contain a policy that the CDM must enforce.  A given
platform may or may not be able to enforce that policy at any given time.  For
example, a license might require output protection, such as HDCP, for high
resolution representations of the content.

Currently, applications can only know if these requirements are met through key
statuses, which are only reported after providing  a license.  To know if a
policy can be enforced, applications must generate a license request, post that
request to a license server, wait for the response, provide the response to the
CDM, wait for key status events, and check key statuses.

Application developers would like to know before fetching content if certain
policies can be enforced.  That would allow the application to start
pre-fetching the best content for that user without starting at a low resolution
or waiting for the license exchange.


## Overview

The new API will allow application developers to query the status of a policy
without a round-trip to the license server.  Because policies and their
enforcement are Key System-specific, policy information will be represented in
Key System-specific, opaque blobs, which could be hard-coded into the
application.

```
partial interface MediaKeys {
  Promise<MediaKeyStatus> getStatusForPolicy(BufferSource policy);
}
```


## Examples

```js
video.mediaKeys.getStatusForPolicy(hdcpPolicy).then(function(status) {
  if (status == 'usable') {
    // Pre-fetch HD content.
  } else {  // such as 'output-restricted' or 'output-downscaled'
    // Pre-fetch SD content.
  }
});
```


## Privacy Considerations

This would allow an application to discover HDCP status using a policy blob
taken from another site.  To mitigate this, we could require policy blobs to be
domain-specific.

As access to this API is gated by `requestMediaKeySystemAccess()`, use of this
API would require user consent (e.g., prompt), if required by the user agent for
the configuration.  This should make it more difficult to abuse the API on those
user agents.
