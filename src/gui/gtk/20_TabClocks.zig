const c = @import("../../c.zig").gtk;

const App = @import("App.zig");

pub const label = "Clocks";

const NULL: ?*anyopaque = null;

pub fn create(_: *App) *c.GtkWidget {
    const view: [*c]c.GtkTreeView = @ptrCast(c.gtk_tree_view_new());
    c.gtk_tree_view_set_enable_tree_lines(view, 1);

    const store: [*c]c.GtkTreeStore = c.gtk_tree_store_new(3, c.G_TYPE_STRING, c.G_TYPE_STRING, c.G_TYPE_STRING);
    c.gtk_tree_view_set_model(view, @ptrCast(store));

    _ = c.gtk_tree_view_insert_column_with_attributes(view, -1, "clock", c.gtk_cell_renderer_text_new(), "text", @as(c_int, 0), NULL);
    _ = c.gtk_tree_view_insert_column_with_attributes(view, -1, "ip", c.gtk_cell_renderer_text_new(), "text", @as(c_int, 1), NULL);
    _ = c.gtk_tree_view_insert_column_with_attributes(view, -1, "port", c.gtk_cell_renderer_text_new(), "text", @as(c_int, 2), NULL);

    var org_iter: c.GtkTreeIter = undefined;
    var building_iter: c.GtkTreeIter = undefined;
    var clock_iter: c.GtkTreeIter = undefined;

    c.gtk_tree_store_append(store, &org_iter, null);
    c.gtk_tree_store_set(store, &org_iter, @as(c_int, 0), "Cancillería", @as(c_int, -1));

    c.gtk_tree_store_append(store, &building_iter, &org_iter);
    c.gtk_tree_store_set(store, &building_iter, @as(c_int, 0), "Edificio 1", @as(c_int, -1));

    c.gtk_tree_store_append(store, &clock_iter, &building_iter);
    c.gtk_tree_store_set(store, &clock_iter, @as(c_int, 0), "Entrada Principal", @as(c_int, 1), "82.254.138.246", @as(c_int, 2), "4277", @as(c_int, -1));

    c.gtk_tree_store_append(store, &clock_iter, &building_iter);
    c.gtk_tree_store_set(store, &clock_iter, @as(c_int, 0), "Entrada Lateral", @as(c_int, 1), "80.171.133.247", @as(c_int, 2), "4271", @as(c_int, -1));

    c.gtk_tree_store_append(store, &clock_iter, &building_iter);
    c.gtk_tree_store_set(store, &clock_iter, @as(c_int, 0), "Estacionamiento", @as(c_int, 1), "70.95.11.51", @as(c_int, 2), "4270", @as(c_int, -1));

    c.gtk_tree_store_append(store, &building_iter, &org_iter);
    c.gtk_tree_store_set(store, &building_iter, @as(c_int, 0), "Edificio 2", @as(c_int, -1));

    c.gtk_tree_store_append(store, &clock_iter, &building_iter);
    c.gtk_tree_store_set(store, &clock_iter, @as(c_int, 0), "Entrada Única", @as(c_int, 1), "81.254.138.206", @as(c_int, 2), "4270", @as(c_int, -1));

    c.gtk_tree_view_expand_all(view);

    // --- Q: Is this necessary? ---
    //
    // The tree view has acquired its own reference to the
    //  model, so we can drop ours. That way the model will
    //  be freed automatically when the tree view is destroyed
    c.g_object_unref(store);

    return @ptrCast(view);
}

pub fn create_label() *c.GtkWidget {
    return c.gtk_label_new(label);
}
