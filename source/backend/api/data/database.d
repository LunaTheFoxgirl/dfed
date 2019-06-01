module backend.api.data.database;
import backend.settings;
import rocksdb;
import std.traits;
import std.meta;
import std.path;
import std.file;
import std.conv;
import asdf;

/// This UDA makes the Database manager ignore this item
struct dbIgnore;

/// Name of key in database
struct dbName { string name; }

/// Path string for where the type is positioned
struct dbPath { string path; }

struct DB {
private:
    Database rdb;
    string dbpath;

    string verifyRDNN(T)(string RDNN) {
        // Make sure there's a reverse domain name to manage.
        if (RDNN is null) {
            static if (!hasUDA!(T, dbPath)) {
                assert(0, "No RDNN was specified and no dbPath specified for "~T.stringof~"!");
            } else {
                return getUDAs!(T, dbPath)[0].path;
            }
        }
        return RDNN;
    }

public:

    this(string file) {
        // Create path to database.
        dbpath = buildPath(SETTINGS.backend.databaseDirectory, file);

        // Make sure the root path for the databases exist.
        if (!exists(SETTINGS.backend.databaseDirectory)) {
            mkdirRecurse(SETTINGS.backend.databaseDirectory);
        }

        /// Open the RocksDB database.
        DBOptions opts = new DBOptions();
        opts.createIfMissing(true);
        rdb = new Database(opts, dbpath);
    }

    @property ref Database rocksdb() {
        return rdb;
    }

    /++
        Saves the database instance
    +/
    void save(T)(T data, string RDNN = null) {

        // If the type is a class or struct, serialize every sub type of the class/struct
        static if (is(T == class) || is (T == struct)) {

            // Make sure there's a reverse domain name to manage.
            RDNN = verifyRDNN!T(RDNN);

            /// Iterate over every type that isn't marked as ignored in the class/struct and serialize those.
            /// This is done at compiletime for maximum efficiency.
            alias fieldTypes = Fields!T;
            alias fieldNames = FieldNameTuple!T;
            static foreach(i, _; fieldTypes) {
                static if (!hasUDA!(__traits(getMember, data, fieldNames[i]), dbIgnore)) {
                    this.save!(fieldTypes[i])(__traits(getMember, data, fieldNames[i]), RDNN~"."~fieldNames[i]);
                }
            }
        } else {
            assert(RDNN, "RDNN was empty, basic types does not support dbPath!");

            /// Otherwise, do a simple json serialization.
            rdb.put(cast(ubyte[])(RDNN), cast(ubyte[])serializeToJson(data));
        }
    }

    T get(T)(string RDNN = null) {
        static if (is(T == class)) {
            T output = new T();
        } else {
            T output = T.init;
        }

        // If the type is a class or struct, serialize every sub type of the class/struct
        static if (is(T == class) || is (T == struct)) {

            // Make sure there's a reverse domain name to manage.
            RDNN = verifyRDNN!T(RDNN);

            /// Iterate over every type that isn't marked as ignored in the class/struct and deserialize those.
            /// This is done at compiletime for maximum efficiency.
            alias fieldTypes = Fields!T;
            alias fieldNames = FieldNameTuple!T;
            static foreach(i, _; fieldTypes) {
                static if (!hasUDA!(__traits(getMember, output, fieldNames[i]), dbIgnore)) {
                    __traits(getMember, output, fieldNames[i]) = this.get!(fieldTypes[i])(RDNN~"."~fieldNames[i]);
                }
            }
        } else {
            assert(RDNN, "RDNN was empty, basic types does not support dbPath!");
            output = deserialize!(T)(cast(string)rdb.get(cast(ubyte[])RDNN));
        }
        return output;
    }

    void remove(T)(T data, string RDNN = null) {
        static if (is(item == class) || is (item == struct)) {

            // Make sure there's a reverse domain name to manage.
            RDNN = verifyRDNN!T(RDNN);


            // Iterate through all non-ignored members and remove them from the DB.
            alias fieldTypes = Fields!T;
            alias fieldNames = FieldNameTuple!T;
            static foreach(i, _; fieldTypes) {
                static if (!hasUDA!(item, dbIgnore)) {
                    this.remove!(item)(RDNN~"."~fieldNames[i], __traits(getMember, data, fieldNames[i]));
                }
            }
        } else {
            assert(RDNN, "RDNN was empty, basic types does not support dbPath!");

            // Remove element from db via the RDNN
            rdb.remove(cast(ubyte[])(RDNN));
        }
    }
}

__gshared static DB DB_INSTANCE;

shared static this() {
    DB_INSTANCE = DB("dfed");
}