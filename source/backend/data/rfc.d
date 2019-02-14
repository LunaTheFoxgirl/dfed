module backend.data.rfc;
import backend.data.rfctokens;
import std.algorithm.searching;
import std.conv;

/// (WIP) Implementation of XSDDuration.
struct XSDDuration {
public:
    /// Offset of years
    size_t years;

    /// Offset of months
    size_t months;

    /// Offset of days
    size_t days;

    /// Offset of hours
    size_t hours;

    /// Offset of minutes
    size_t minutes;

    /// Offset of seconds
    double seconds = 0;
    
    /// constructor
    this(string data) {
        Token[] tokens = parseDuration(data);

        // parse tokens
        foreach(Token tk; tokens) {
            immutable(bool) isDecimalToken = tk.token.canFind(".");
            double tkDouble = isDecimalToken ? tk.token.to!double : cast(double)(tk.token.to!int);
            switch (tk.type) {

                case (TokenType.tkDurationYear):
                    years = cast(size_t)tkDouble;
                    break;
                case (TokenType.tkDurationMonth):
                    months = cast(size_t)tkDouble;
                    break;
                case (TokenType.tkDurationDay):
                    days = cast(size_t)tkDouble;
                    break;

                case (TokenType.tkDurationHour):
                    hours = cast(size_t)tkDouble;
                    break;
                case (TokenType.tkDurationMinute):
                    minutes = (cast(size_t)tkDouble);
                    break;
                case (TokenType.tkDurationSecond):
                    seconds = tkDouble;
                    break;
                default: break;
            }
        }
    }

    string toString() {
        string o = "P";
        o ~= years != 0 ? years.text~"Y" : "";
        o ~= months != 0 ? months.text~"M" : "";
        o ~= days != 0 ? days.text~"D" : "";
        if (hours != 0 || minutes != 0 || seconds != 0) {
            o ~= "T";
            o ~= hours != 0 ? hours.text~"H" : "";
            o ~= minutes != 0 ? minutes.text~"M" : "";
            o ~= seconds != 0 ? seconds.text~"S" : "";
        }
        return o;
    }
}

unittest {
    XSDDuration dur;
    dur.hours = 42;
    assert(dur.toString == "PT42H", dur.toString);

    dur.hours = 0;
    dur.years = 4;
    dur.months = 20;
    assert(dur.toString == "P4Y20M", dur.toString);

    dur.years = 4;
    dur.months = 20;
    dur.hours = 1;
    dur.minutes = 2;
    dur.seconds = 3;
    assert(dur.toString == "P4Y20MT1H2M3S", dur.toString);
}