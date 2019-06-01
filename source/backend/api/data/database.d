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
        /// Make sure there's a reverse domain name to manage.
        if (RDNN is null) {
            static if (!hasUDA!(T, dbPath)) {
                static assert(0, "No RDNN was specified and no dbPath specified for type!");
            }
            RDNN = getUDAs!(T, dbPath)[0].path;
        }

        static if (is(item == class) || is (item == struct)) {
            alias fieldTypes = Fields!T;
            alias fieldNames = FieldNameTuple!T;
            static foreach(i, _; fieldTypes) {
                static if (!hasUDA!(item, dbIgnore)) {
                    this.save!(item)(RDNN~"."~fieldNames[i], __traits(getMember, data, fieldNames[i]));
                }
            }
        } else {
            rdb.put(cast(ubyte[])(RDNN), cast(ubyte[])serializeToJson(data));
        }
    }

    T get(T)(string RDNN = null) {
        /// Make sure there's a reverse domain name to manage.
        if (RDNN is null) {
            static if (!hasUDA!(T, dbPath)) {
                static assert(0, "No RDNN was specified and no dbPath specified for type!");
            }
            RDNN = getUDAs!(T, dbPath)[0].path;
        }

        static if (is(item == class) || is (item == struct)) {
            T output;
            alias fieldTypes = Fields!T;
            alias fieldNames = FieldNameTuple!T;
            static foreach(i, _; fieldTypes) {
                static if (!hasUDA!(item, dbIgnore)) {
                    __traits(getMember, output, fieldNames[i]) = this.get!(fieldTypes[i])(RDNN~"."~fieldNames[i]);
                }
            }
            return output;
        } else {
            return deserialize!(T)(cast(string)rdb.get(cast(ubyte[])RDNN));
        }
    }

    void remove(T)(T data, string RDNN = null) {
        /// Make sure there's a reverse domain name to manage.
        if (RDNN is null) {
            static if (!hasUDA!(T, dbPath)) {
                static assert(0, "No RDNN was specified and no dbPath specified for type!");
            }
            RDNN = getUDAs!(T, dbPath)[0].path;
        }

        static if (is(item == class) || is (item == struct)) {
            alias fieldTypes = Fields!T;
            alias fieldNames = FieldNameTuple!T;
            static foreach(i, _; fieldTypes) {
                static if (!hasUDA!(item, dbIgnore)) {
                    this.remove!(item)(RDNN~"."~fieldNames[i], __traits(getMember, data, fieldNames[i]));
                }
            }
        } else {
            rdb.remove(cast(ubyte[])(RDNN));
        }
    }
}

__gshared static DB DB_INSTANCE;

@dbPath("hell._test")
private struct _test {
    int val1;
    int val2;
}

shared static this() {
    DB_INSTANCE = DB("dfed");
    _test t;
    t.val1 = 42;
    t.val2 = 34;
    DB_INSTANCE.save(t);

    import std.stdio : writeln;
    _test t2 = DB_INSTANCE.get!_test;
    writeln(t2);
}