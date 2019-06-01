module backend.api.data.crypto;
import crypto.rsa;
import secured.kdf;
import secured.random;

/// Database password
struct DBPasswd {
    ubyte[] hash;
    ubyte[] salt;

    this(string password, ubyte[] salt = []) {
        this.salt = salt == [] ? random(256) : salt;
        hash = scrypt_ex(password, this.salt, 1_048_576, 8, 1, 1_074_790_400, 128);
    }

    this(ubyte[] hash, ubyte[] salt) {
        this.hash = hash;
        this.salt = salt;
    }

    bool verify(string password) {
        DBPasswd passwd = DBPasswd(password, this.salt);
        return passwd.hash == this.hash;
    }
}

struct DBKeypair {
    /// The user's private key
    string privateKey;

    /// The user's public key
    string publicKey;
}

DBKeypair newKP() {
    RSAKeyPair keypair = RSA.generateKeyPair(2048);
    return DBKeypair(keypair.privateKey, keypair.publicKey);
}
