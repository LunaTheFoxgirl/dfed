module backend.data.activitystreams;
import asdf;
import backend.data.ld;
import std.traits;
import std.format;

public:
/// Language key for @context
struct ActivityLang {
    @serializationKeys("@language")
    string language;
}

private string genRefInstantiate() {
    static if (is(typeof(this) == struct)) {
        return q{list ~= T(r);};
    } else {
        return q{list ~= new T(r);};
    }
}

private string genRefReturn() {
    static if (is(typeof(this) == struct))  {
        return q{return T(r);};
    } else {
        return q{return new T(r);};
    }
}

// Check that the type has a compatible constructor.
// Also make sure we can check wether it was read as reference.
// Also make sure getReference exists so that we can get the value when serializing.
enum IsValidActivityRef(T) = ((isCallable!(T, string) || isCallable!(T.ctor, string)) && __traits(hasMember, T, "isReference") && __traits(hasMember, T, "getReference"));

/// A list of activity references.
struct ActivityRefList(T) if (IsValidActivityRef!T) {
public:
    /// The list of items.
    T[] list;

    static ActivityRefList deserialize(Asdf data) {
        if (data.kind == Asdf.Kind.array) {
            auto range = data.byElement();
            while(!range.empty) {
                list ~= T.deserialize(range);

                // pop for next value
                range.popFront;
            }
        } else {
            list ~= T.deserialize(data);
        }
        return ctx;
    }

    /// serialize activity context properly.
    void serialize(S)(ref S serializer) {
        // start making an array
        auto state = serializer.arrayBegin;

        foreach(var; list) {

            // Add index.
            serializer.elemBegin;
            var.serialize();

        }
        // end the array.
        serializer.arrayEnd(state);
    }
}

/// A reference to an activitystreams item.
mixin template ActivityRef() {
private:
    alias ThisType = typeof(this);

public:
    // Make sure that the type has a compatible constructor.
    // Also make sure we can check wether it was read as reference.
    // Also make sure getReference exists so that we can get the value when serializing.
    static if (IsValidActivityRef!T) {
        
        /// Deserialize activity context properly.
        static ThisType deserialize(Asdf data) {
            if (data.kind == Asdf.Kind.string) {
                string r;

                // Just a good old string.
                deserializeScopedString(data, r);

                // Generate the instantiator for string/reference
                mixin(genRefReturn);
            } else {
                // Object representation
                T o;
                deserializeValue(data, o);

                // Add reference to list
                list ~= o;

            }
            return ctx;
        }

        /// serialize activity context properly.
        void serialize(S)(ref S serializer) {
            if (isReference) {
                serializer.serializeValue(getReference);
            } else {
                serializer.serializeValue(this);
            }
        }
    } else {
        static assert("Failed implementing the interface, make sure there's a constructor accepting a string and isReference (bool) is implemented.");
    }
}

/// @context implementation that supports language key.
struct ActivityContextList {
public:
    /// @context
    string context;
    
    /// @language (object)
    ActivityLang language;

    /// Deserialize activity context properly.
    static ActivityContextList deserialize(Asdf data) {
        ActivityContextList ctx;
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

/// An activity collection
struct ActivityCollection(T, CType = Ignored, bool strictOrdering = false) {
public:
    mixin ActivityObject!("Collection");

    // TODO: implement strictOrdering

    /++ 
        A non-negative integer specifying the total number of objects contained by the logical view of the collection. 
        This number might not reflect the actual number of items serialized within the Collection object instance. 
    +/
    @serializationRequired
    @serializationKeys("totalItems")
    int totalItems() {
        return items.list.length;
    }


    /// Identifies the items contained in a collection. The items might be ordered or unordered.
    @serializationRequired
    @serializationKeys("items")
    ActivityRefList!T items;

    /// In a paged Collection, indicates the furthest preceeding page of items in the collection.
    @serializationKeys("first")
    string first;

    static if (CType != typeof(Ignored)) {

        /// In a paged Collection, indicates the page that contains the most recently updated member items.
        @serializationKeys("current")
        ActivityRef!T current;
    } else {

        // This version only accepts strings for current definition.

        /// In a paged Collection, indicates the page that contains the most recently updated member items.
        @serializationKeys("current")
        string current;
    }

    /// In a paged Collection, indicates the furthest proceeding page of the collection.
    @serializationKeys("last")
    string last;
}

/// TODO: implement the ordered collection implementation (inside ActivityCollection)
alias ActivityOrderedCollection(T, CType = Ignored) = ActivityCollection!(T, Ignored, true);

/// An basic ActivityStreams object.
mixin template ActivityObject(string acceptedObjectType = "Object", string itemName = "id") {
    mixin LDObject!Ignored;

    /// The valid type for this activity streams object.
    enum ValidType = acceptedObjectType;

    /// Get wether this object is a valid instance.
    bool isValidObject() {
        if (type == ValidType) {
            return true;
        }
        return false;
    }

    @serializationIgnore
    bool isReference;

    @serializationIgnore
    string getReference () {
        // import std.format here since it's a mixin.
        import std.format : format;
        return mixin(q{%s}.format(itemName));
    }

    /// Special context object.
    @serializationRequired
    @serializationKeys("@context")
    ActivityContextList context;


    /// type
    @serializationRequired
    @serializationKeys("type")
    string type;

    /// id
    @serializationKeys("id")
    string id;

    /// name
    @serializationKeys("name")
    string name;
}
