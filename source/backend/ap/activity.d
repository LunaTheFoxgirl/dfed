module backend.ap.activity;
import vibe.data.json;
import std.format;
import backend.settings;
import std.datetime;

enum ActivityTypes : string {
    Create = "Create"
}

struct ActivityObject {
    /// Id of the object
    string id;

    /// Type of the object
    string type;

    /// date/time the activity was published
    DateTime published;

    /// Who the activity is attributed to
    @optional
    string attributedTo;

    /// What activity this activity is replying to
    @optional
    string inReplyTo;

    /// The content
    string content;

    /// The mode
    @optional
    string[] to;

    @optional
    string[] cc;
}

struct Activity {
    string id;
    ActivityTypes type;
    string actor;

    Json getJson() {
        return serializeToJson(this);
    }
}