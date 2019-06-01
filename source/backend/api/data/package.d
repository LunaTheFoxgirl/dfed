module backend.api.data;
import backend.api.data.database;

/++
    A model is a class containing data that can be saved in a database.
+/
class Model {
    abstract string getRDNN();

    void saveModel(T)(T item) if (is(T : Model)) {
        DB_INSTANCE.save!T(getRDNN(), item);
    }
}