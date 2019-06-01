module backend.webfinger;
import vibe.d;

struct WebFingerLink {
    /// Relation
    string rel = "self";

    /// Type 
    string type = "application/activity+json";

    /// Reference
    string href;
}

struct WebFingerInfo {
    /// Subject of response
    string subject;

    /// Links associated
    WebFingerLink[] links;
}

@path("/.well-known/")
class WebFingerController {
    @path("webfinger")
    @queryParam("resource", "resource")
    Json getWebfinger(string resource) {
        WebFingerInfo info;
        info.subject = resource;

        // TODO: Fill out webfinger data.

        return serializeToJson(info);
    }
}