module backend.settings;
import vibe.http.server;
import vibe.core.log;
import core.time;
import asdf;
import std.file : readText, exists;
import core.stdc.stdlib;

/// Settings for the server backend (vibe.d)
final class ServerSettingsBackend {
    /// Port to bind to.
    @serializationKeys("port")
    ushort port = 80;

    /// Addresses to bind to
    @serializationKeys("bindings")
    string[] bindAddresses = ["::", "0.0.0.0"];

    /// Host name
    @serializationKeys("hostname")
    string hostName;

    @serializationKeys("root_address")
    @serializationRequired
    string rootAddress;
    
    /// Max time a request may take to execute. (in milliseconds)
    @serializationKeys("request_timeout")
    uint maxRequestTime = 0;

    /// Max time waited before connection times out after no data. (in milliseconds)
    @serializationKeys("keepalive_timeout")
    uint keepAliveTimeout = 10;

    /// Max size of an request.
    @serializationKeys("max_request_size")
    ulong maxRequestSize = 2_097_152;

    /// Max size of header.
    @serializationKeys("max_header_size")
    ulong maxHeaderSize = 8_192;

    /// Name of session cookie.
    @serializationKeys("cookie_id")
    string sessionIdCookie = "dfedSession";

    /// Name of server.
    @serializationKeys("server_name")
    string serverString = "dfed vibe-d";

    /// Where to store logs
    @serializationKeys("log_dir")
    string logDirectory = "access.log";

    @serializationKeys("db_dir")
    string databaseDirectory = "db/";
}

/// Settings for dfed functionality.
final class DFedSettings {

    /// Wether the server should try to stay mastodon compatible.
    @serializationKeys("mastodon_compatiblity", "compat_mastodon")
    bool mastodonCompatMode = true;

    /// Wether user registrations should be allowed.
    @serializationKeys("allow_registrations")
    bool allowRegistrations = true;

    /// Wether two factor authentication should be enabled.
    @serializationKeys("two_factor")
    bool twoFactorAuthentication = false;

    /// Wether the server should federate with others.
    @serializationKeys("federation")
    bool federation = true;
}


/// Settings for the dfed server.
struct ServerSettings {
   
    /// Settings for the backend (ip, routing, etc.)
    @serializationKeys("backend")
    ServerSettingsBackend backend;

    /// Settings for the DFed server (compatiblity, defaults, etc.)
    @serializationKeys("settings")
    DFedSettings settings;

    /// Debugging mode.
    @serializationKeys("debug")
    bool dbgMode = false;

    /// Convert to HTTPServerSettings for consumption internally.
    HTTPServerSettings toServerSettings() {
        HTTPServerSettings xset = new HTTPServerSettings;
        xset.port = backend.port;
        xset.bindAddresses = backend.bindAddresses;
        xset.hostName = backend.hostName;
        xset.maxRequestTime = backend.maxRequestTime.msecs;
        xset.keepAliveTimeout = backend.keepAliveTimeout.msecs;
        xset.maxRequestSize = backend.maxRequestSize;
        xset.maxRequestHeaderSize = backend.maxHeaderSize;
        xset.sessionIdCookie = backend.sessionIdCookie;
        xset.serverString = backend.serverString;
        import std.path : buildPath;
        xset.accessLogFile = buildPath(backend.logDirectory, "access.log");
        return xset;
    }
}

/// Public settings instance usable throughout the application.
ServerSettings SETTINGS;

/// TODO: translate these?
private enum JSONParseError = "Failed to parse json: %s; try checking the example configuration that came with your DChirp installation.";
private enum GeneralError = "Failed to load configuration, reason: %s";

shared static this() {
    logInfo("Loading configuration...");

    // Try parsing configuration, if failed crash the application.
    try {

        // If config file not found, use defaults
        if (!exists("config.json")) {
            logInfo("Configuration file not found, using defaults...");
            SETTINGS = ServerSettings(new ServerSettingsBackend, new DFedSettings);
            return;
        }

        // Otherwise use config specified
        SETTINGS = (readText("config.json").deserialize!ServerSettings);

        if (SETTINGS.dbgMode) {
            import std.conv : text;
            logInfo("Loaded configuration from file!\n%s", SETTINGS.serializeToJson);
        } else {
            logInfo("Loaded configuration from file!");
        }
    } catch(AsdfException ex) {

        // Force exit, json formatting error.
        logFatal(JSONParseError, ex.msg);
        exit(22);
    } catch (Exception ex) {

        // Force exit, this error is fatal. (unknown, so just general error.)
        logFatal(GeneralError, ex.msg);
        exit(-1);
    }
}
