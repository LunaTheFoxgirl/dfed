module experiments.activitypub;
import backend.data.activitystreams;
import backend.data.ld;
import asdf;
/*
struct ActivityStatus {

    mixin LDObject;

    /// type
    @serializationRequired
    @serializationKeys("type")
    string type;
}

struct ActivitySource {
    /// content
    @serializationRequired
    @serializationKeys("content")
    string content;

    /// mediaType
    @serializationRequired
    @serializationKeys("mediaType")
    string mediaType;

}

struct ActivityActor {

    // This struct is an ActivityObject, and when referenced use id.
    mixin ActivityObject;

    /// following
    @serializationRequired
    @serializationKeys("following")
    string following;

    /// followers
    @serializationRequired
    @serializationKeys("followers")
    string followers;

    /// liked
    @serializationRequired
    @serializationKeys("liked")
    string liked;

    /// inbox
    @serializationRequired
    @serializationKeys("inbox")
    string inbox;

    /// outbox
    @serializationRequired
    @serializationKeys("outbox")
    string outbox;

    /// preferredUsername
    @serializationRequired
    @serializationKeys("preferredUsername")
    string preferredUsername;

    /// name
    @serializationRequired
    @serializationKeys("name")
    string name;

    /// summary
    @serializationRequired
    @serializationKeys("summary")
    string summary;

    /// icon
    @serializationRequired
    @serializationKeys("icon")
    string[] icon;
    
}

unittest {
    import std.stdio;
    string testData = `
{
    "@context": ["https://www.w3.org/ns/activitystreams",
                {"@language": "en"}],
    "type": "Note",
    "id": "http://postparty.example/p/2415",
    "content": "<p>I <em>really</em> like strawberries!</p>",
    "source": {
        "content": "I *really* like strawberries!",
        "mediaType": "text/markdown"}
}`;
    ActivityStatus ctx = deserializeLDFrom!ActivityStatus(testData);
    writeln(ctx);
}*/