module backend.ap.actor;
import vibe.data.json;
import std.format;
import backend.settings;

struct ActorKeypair {
    string id;
    string owner;
    string publicKeyPem;
}

/++
    Actor implements a basic ActivityPub actor.
+/
struct Actor {
private:
    string link = null;

public:
    /// Returns true if the actor object is a link
    bool isLinked() {
        return (link !is null);
    }

    /// The context for the object
    @optional
    string[] context = [
        "https://www.w3.org/ns/activitystreams",
		"https://w3id.org/security/v1"
    ];

    /// The ID of the object
    string id;

    /// The type of the object
    @optional
    string type = "Person";

    /// The preferred username for the user
    @optional
    string preferredUsername;

    /// Display name
    @optional
    @name("name")
    string displayName;

    /// The bio
    @optional
    @name("summary")
    string bio;

    /// The user's profile picture
    @optional
    string icon;

    /// Link to the inbox
    @optional
    string inbox;

    /// Link to the outbox
    @optional
    string outbox;

    /// Link to the following list
    @optional
    string following;

    /// Link to the followers list
    @optional
    string followers;

    /// Link to the likes list
    @optional
    string liked;

    /// GPG keypair
    ActorKeypair publicKey;

    Json getJson() {
        return serializeToJson(this);
    }
}