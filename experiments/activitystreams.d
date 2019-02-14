module backend.data.activitystreams;
import asdf;
import std.traits;
/+
public class BaseFactory {
private:
    Base[string] factories;

public:
    void addFactory(string name, Base type) {
        factories[name] = type;
    }

    Base doInit(string name) {
        return factories[name].newThis();
    }

    Base doInit(string name, string refUrl) {
        return factories[name].newThis(refUrl);
    }
}

public class Base {
protected:
    /// URL being referenced
    string refUrl;
public:

    // new empty instance, does nothing fill in data.
    this() {

    }

    // new instance, has reference URL.
    this(string refurl) {
        this.refUrl = refurl;
    }

    abstract Base newThis();
    abstract Base newThis(string refUrl);

    /// Called when serializing, override this.
    /*void serializeSelf(ref AsdfSerializer serializer) {
        serializer.putKey("@context");
        serializer.putValue(context);
        serializer.putKey("type");
        serializer.putValue(type);
    }

    /// Called when deserializing, override this.
    void deserializeFrom(Asdf data) {
        if (!"type".doesExist(data)) throw new Exception("Type no specified");
        type = data["type"].get("");

        // TODO: parse context as a special thing?
        if ("@context".doesExist(data))
            context = data["@context"].get("");
    }


    /// Asdf impl
    static Base deserialize(Asdf data) {
        Base baseType = cast(Base)FACTORIES.doInit(data["type"].get(""));
        baseType.deserializeFrom(data);
        return baseType;
    }

    /// Asdf impl
    void serialize(ref AsdfSerializer serializer) {
        serializeSelf(serializer);
    }*/

    /// type
    @serializationRequired
    @serializationKeys("type")
    string type;

    /// @context
    @serializationRequired
    @serializationKeys("@context")
    string context;
}

/// tests wether an index exists in the json data.
bool doesExist(string index, Asdf data) {
    import std.array : split;
    string[] strs = index.split(".");
    Asdf sub;
    foreach(idex; strs) {
        sub = data[idex];
        if (sub.data.length <= 0) return false;
        if (sub.kind == Asdf.Kind.null_) return false;
    }
    return true;
}

public class Link : Base {
public:
    /// href
    string href;

    /// hreflang
    string hreflang;

    /// mediaType
    string mediaType;

    /// name
    string[] names;

    /// name
    string[string] nameMap;

    /// rels
    string[] rels;

    /// width
    int width;

    /// height
    int height;

    /// height
    Base preview;

    this() {
        super();
    }

    this(string refUrl) {
        super(refUrl);
    }

    override Base newThis() {
        return new Link();
    }

    override Base newThis(string refUrl) {
        return new Link(refUrl);
    }

    /*override void deserializeFrom(Asdf data) {
        super.deserializeFrom(data);

        if ("href".doesExist(data))
            href = data["href"].get("");

        if ("hreflang".doesExist(data))
            hreflang = data["hreflang"].get("");

        if ("mediaType".doesExist(data))
            mediaType = data["mediaType"].get("");

        if ("name".doesExist(data))
            names ~= data["name"].get("");

        if ("nameMap".doesExist(data))
            names ~= data["nameMap"].get!(string[string])([]);

        if ("rel".doesExist(data))
            rels ~= data["rel"].get("");

        if ("width".doesExist(data))
            width = data["width"].get(0);

        if ("height".doesExist(data))
            height = data["height"].get(0);

        // Will fail if either preview doesn't exist or if type is not specified.
        if ("preview.type".doesExist(data)) {
            preview = FACTORIES.doInit(data["preview"]["type"].get(""));
            preview.deserializeFrom(data);
        }
    }

    override void serializeSelf(ref AsdfSerializer serializer) {
        super.serializeSelf(serializer);

    }*/
}

unittest {
    string json = `
{
  "@context": "https://www.w3.org/ns/activitystreams",
  "type": "Link",
  "href": "http://example.org/abc",
  "hreflang": "en",
  "mediaType": "text/html",
  "name": "An example link"
}`;
    assert(json.deserialize!Base);

}

/// ActivityStreams object, Object is reserved in D.
public class AObject : Base {

}


public class Image : Object {

}

public class Collection : Object {

}

__gshared BaseFactory FACTORIES;

shared static this() {
    FACTORIES = new BaseFactory();
    FACTORIES.addFactory("Link", new Link);
}+/