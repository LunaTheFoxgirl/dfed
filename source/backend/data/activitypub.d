module backend.data.activitypub;
import backend.data.ld;
import asdf;
import std.variant;

// TODO: make languages an enum?

struct ActivityLang {
    @serializationKeys("@language")
    string language;
}

struct ActivityContext {
public:
    /// @context
    string context;
    
    /// @language (object)
    ActivityLang language;

    /// Deserialize activity context properly.
    static ActivityContext deserialize(Asdf data) {
        ActivityContext ctx;
        if (data.kind == Asdf.Kind.array) {
            auto range = data.byElement();
            // @context
            ctx.context = cast(string)range.front;

            // pop for next value
            range.popFront;

            // @language (object)
            deserializeValue(range.front, ctx.language);

        } else if (data.kind == Asdf.Kind.string) {
            // Just a good old string.
            deserializeScopedString(data, ctx.context);
        }
        return ctx;
    }

    /// serialize activity context properly.
    void serialize(S)(ref S serializer) {
        // start making an array
        auto state = serializer.arrayBegin;

        // Add @context
        serializer.elemBegin;
        serializer.serializeValue(context);

        // Add @language (object)
        serializer.elemBegin;
        serializer.serializeValue(language);

        // end the array.
        serializer.arrayEnd(state);
    }
}

struct ActivityStatus {

    mixin LDRootObject!(string, Ignored);

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

mixin template ActivityObject() {
    mixin LDObject!Ignored;

    /// Special context object.
    @serializationRequired
    @serializationKeys("@context")
    ActivityContext context;


    /// type
    @serializationRequired
    @serializationKeys("type")
    string type;

    /// id
    @serializationRequired
    @serializationKeys("id")
    string id;
}

struct ActivityActor {

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
    @serializationRequire
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
}