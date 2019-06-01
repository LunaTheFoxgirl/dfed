module backend.as.ordered;
import vibe.data.json;

struct OrderedCollection {
    string summary;
    Json[] items;

    this(Json data) {
        if (data["type"].opt!string != "OrderedCollection") throw new Exception("Item was not OrderedCollection!");
        summary = data["summary"].get!string;
        items = data["orderedItems"].getDataAs!(Json[]);
    }

    Json getJson() {
        return Json([
            "@context": Json("https://www.w3.org/ns/activitystreams"),
            "summary": Json(summary),
            "type": Json("OrderedCollection"),
            "totalItems": Json(items.length),
            "orderedItems": Json(items)
        ]);
    }
}