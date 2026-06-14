const c = @import("../../../c.zig").gtk;

const App = @import("../App.zig");

pub const label = "Clocks";

const COL_NAME: c_int = 0;
const COL_IP: c_int = 1;
const NULL: ?*anyopaque = null;

pub fn create(_: *App) *c.GtkWidget {
    const view: [*c]c.GtkTreeView = @ptrCast(c.gtk_tree_view_new());

    var renderer: [*c]c.GtkCellRenderer = undefined;
    renderer = c.gtk_cell_renderer_text_new();
    _ = c.gtk_tree_view_insert_column_with_attributes(view, -1, "Clock", renderer, "text", COL_NAME, NULL);
    renderer = c.gtk_cell_renderer_text_new();
    _ = c.gtk_tree_view_insert_column_with_attributes(view, -1, "IP", renderer, "text", COL_IP, NULL);

    var iter: c.GtkTreeIter = undefined;
    const store = c.gtk_list_store_new(2, c.G_TYPE_STRING, c.G_TYPE_STRING);
    c.gtk_list_store_append(store, &iter);
    c.gtk_list_store_set(store, &iter, COL_NAME, "Cancillería Entrada Principal", COL_IP, "82.254.138.246", @as(c_int, -1));
    c.gtk_list_store_append(store, &iter);
    c.gtk_list_store_set(store, &iter, COL_NAME, "Cancillería Entrada Lateral", COL_IP, "80.171.133.247", @as(c_int, -1));
    c.gtk_list_store_append(store, &iter);
    c.gtk_list_store_set(store, &iter, COL_NAME, "Cancillería Estacionamiento", COL_IP, "70.95.11.51", @as(c_int, -1));

    c.gtk_tree_view_set_model(view, @ptrCast(store));

    // The tree view has acquired its own reference to the
    //  model, so we can drop ours. That way the model will
    //  be freed automatically when the tree view is destroyed
    c.g_object_unref(store);

    return @ptrCast(view);
}

pub fn create_label() *c.GtkWidget {
    return c.gtk_label_new(label);
}
