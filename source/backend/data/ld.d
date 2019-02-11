module backend.data.ld;
import asdf;
import std.traits;

/// Specify that an LDRootObject (@type) should be ignored.
struct Ignored;

enum IsLDObject(T) = (
    __traits(hasMember, T, "serializeLDJson") && 
    __traits(hasMember, T, "context"));

/// Deserialize LD-JSON data from string
T deserializeLDFrom(T)(string ldjson) if (IsLDRootObject!T || IsLDObject!T) {
    return ldjson.deserialize!T;
}

mixin template LDObject(ctxType = string) {
    static if (!is(ctxType : Ignored)) {
        /// Context Type
        @serializationRequired
        @serializationKeys("@context")
        ctxType context;
    }


    /// Serialize this instance to LD-JSON
    string serializeLDJson() {
        return serializeToJson(this);
    }
}

//// ================================ UNIT TESTS =================================


// action
private struct ldAction {
public:
    mixin LDObject;

    string name;
}

// root object
private struct ldActionObject {
public:
    mixin LDObject;

    @serializationKeys("@type")
    string type;

    @serializationKeys("agent")
    ldAction agent;

    @serializationKeys("object")
    ldAction object;

    @serializationKeys("participant")
    ldAction participant;

    @serializationKeys("location")
    ldAction location;

    @serializationKeys("instrument")
    ldAction instrument;
}

unittest {
    string compData = `{"@context":"http://schema.org","@type":"ListenAction","agent":{"@type":"Person","name":"John"},"object":{"@type":"MusicGroup","name":"Pink!"},"participant":{"@type":"Person","name":"Steve"},"location":{"@type":"Residence","name":"Ann's apartment"},"instrument":{"@type":"Product","name":"iPod"}}`;
    string testData = 
`{
    "@context": "http://schema.org",
    "@type": "ListenAction",
    "agent": {
        "@type": "Person",
        "name": "John"
    },
    "object": {
        "@type": "MusicGroup",
        "name": "Pink!"
    },
    "participant": {
        "@type": "Person",
        "name": "Steve"
    },
    "location": {
        "@type": "Residence",
        "name": "Ann's apartment"
    },
    "instrument": {
        "@type": "Product",
        "name": "iPod"
    }
}`;
    ldActionObject root = deserializeLDFrom!ldActionObject(testData);
    assert(root.serializeLDJson == compData, "Data does not match!");
}