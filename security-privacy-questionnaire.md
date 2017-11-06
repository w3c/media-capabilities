# Media Capabilities - Security and Privacy Questionnaire

This document answers the [W3C Security and Privacy
Questionnaire](https://www.w3.org/TR/security-privacy-questionnaire/)for the
Media Capabilities specification.

Last Update: 2017-11-06

**Does this specification deal with personally-identifiable information?**

No.

**Does this specification deal with high-value data?**

No.

**Does this specification introduce new state for an origin that persists across
browsing sessions?**

No.

**Does this specification expose persistent, cross-origin state to the web?**

The Media Capabilities of a device are somewhat persistent user information that
will be easier to access. Indeed, websites can guess this information by playng
media and checking the dropped frames. Exposed information can also heavily
correlate with other information such as device model.

**Does this specification expose any other data to an origin that it doesn’t
currently have access to?**

No.

**Does this specification enable new script execution/loading mechanisms?**

No.

**Does this specification allow an origin access to a user’s location?**

No.

**Does this specification allow an origin access to sensors on a user’s
device?**

No.

**Does this specification allow an origin access to aspects of a user’s local
computing environment?**

Not directly. The exposed persistent information could be used to guess the
local computing environment simalarly to what web pages can do today by running
local benchmark.

**Does this specification allow an origin access to other devices?**

No.

**Does this specification allow an origin some measure of control over a user
agent’s native UI?**

No.

**Does this specification expose temporary identifiers to the web?**

No.

**Does this specification distinguish between behavior in first-party and
third-party contexts?**

No.

**How should this specification work in the context of a user agent’s
"incognito" mode?**

The feature should not behave differently in incognito mode.

**Does this specification persist data to a user’s local device?**

One implementation strategy would be to store data about historical decoding
information in order to provide better values to the querying API. When such an
implementation strategy is used, the data should be cleared when users clear
their browser information.

**Does this specification have a "Security Considerations" and
"Privacy Considerations" section?**

[Yes](https://wicg.github.io/media-capabilities/#security-privacy-considerations).

**Does this specification allow downgrading default security characteristics?**

No.
