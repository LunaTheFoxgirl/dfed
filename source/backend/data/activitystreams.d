module backend.data.activitystreams;
import asdf;
import backend.data.ld;

public:
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
