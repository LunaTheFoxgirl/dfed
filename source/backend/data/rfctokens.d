module backend.data.rfctokens;
import core.time;
import std.uni;
import std.conv;

/// Types of valid tokens in XSD
enum TokenType : ubyte {
    tkDurationDate,
    tkDurationYear,
    tkDurationMonth,
    tkDurationDay,
    tkDurationTime,
    tkDurationHour,
    tkDurationMinute,
    tkDurationSecond
}

/// A token.
struct Token {
    /// The type of token
    TokenType type;

    /// The token
    string token;
}

Token[] parseDuration(string duration) {
    Token curToken;
    TokenType sep = TokenType.tkDurationDate;
    Token[] tokens;
    foreach(i, char c; duration) {
        if (i == 0 && c != 'P') {
            throw new Exception("Invalid Duration expression");
        }

        // The number of the token
        if (isNumber(c) || c == '.') {
            curToken.token ~= c;
            continue;
        }

        // Parse the type
        switch(c) {
            case('Y'):
                if (sep == TokenType.tkDurationDate) {
                    curToken.type = TokenType.tkDurationYear;
                } else {
                    throw new Exception("Unexpected YEAR in TIME section!");
                }
                break;

            case('M'):
                if (sep == TokenType.tkDurationDate) {
                    curToken.type = TokenType.tkDurationMonth;
                } else {
                    curToken.type = TokenType.tkDurationMinute;
                }
                break;

            case('D'):
                if (sep == TokenType.tkDurationDate) {
                    curToken.type = TokenType.tkDurationDay;
                } else {
                    throw new Exception("Unexpected DAY in TIME section!");
                }
                break;

            case('H'):
                if (sep == TokenType.tkDurationTime) {
                    curToken.type = TokenType.tkDurationHour;
                } else {
                    throw new Exception("Unexpected HOUR in DATE section!");
                }
                break;

            case('S'):
                if (sep == TokenType.tkDurationTime) {
                    curToken.type = TokenType.tkDurationSecond;
                } else {
                    throw new Exception("Unexpected SECOND in DATE section!");
                }
                break;

            default:
                throw new Exception("Unexpected " ~ c.text ~ " at index " ~ i.text);
        }
        tokens ~= curToken;

        if (curToken.type == TokenType.tkDurationDate || curToken.type == TokenType.tkDurationTime) 
            throw new Exception("Invalid token type...");
        if (curToken.token == "")
            throw new Exception("Dataless section!");
        // Next token...
        curToken = Token(TokenType.tkDurationDate, "");
    }
    return tokens;
}