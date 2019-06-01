module backend.api.data.user;
import backend.api.data.database;
import backend.api.data.crypto;

struct DBUserSettings {
    string icon;
    string nickname;
}

@dbPath("users/:id")
struct DBUser {
    /// Id of the user
    string id;
    
    /// Email of user
    string email;

    /// Username of user
    string username;

    /// The settings the user has applied
    DBUserSettings settings;

    /// The hashed password
    DBPasswd password;

    /// RSA keypair
    DBKeypair rsa;
}

/// Create a new user account
DBUser createNewUser(string email, string username, string passwd) {
    DBUser user;
    user.email = email;
    user.username = username;
    user.settings.nickname = username;
    user.password = DBPasswd(passwd);
    user.rsa = newKP();
    return user;
}

class User {
    this(string email, string username, string passwd) {
        import std.traits;
        
    }
}
