const std = @import("std");
const log = std.log;

const ClocksTree = @import("../../model/ClocksTree.zig");

const c = @import("c.zig").gtk;

const App = @import("App.zig");

pub const label = "Clocks";

const NULL: ?*anyopaque = null;

pub fn create(app: *App) *c.GtkWidget {
    const ct: ClocksTree = ClocksTree.get(app.conn) catch @panic("Merda!");
    defer ct.free();

    const view: [*c]c.GtkTreeView = @ptrCast(c.gtk_tree_view_new());
    c.gtk_tree_view_set_enable_tree_lines(view, 1);

    const store: [*c]c.GtkTreeStore = c.gtk_tree_store_new(3, c.G_TYPE_STRING, c.G_TYPE_STRING, c.G_TYPE_STRING);
    c.gtk_tree_view_set_model(view, @ptrCast(store));

    _ = c.gtk_tree_view_insert_column_with_attributes(view, -1, "clock", c.gtk_cell_renderer_text_new(), "text", @as(c_int, 0), NULL);
    _ = c.gtk_tree_view_insert_column_with_attributes(view, -1, "ip", c.gtk_cell_renderer_text_new(), "text", @as(c_int, 1), NULL);
    _ = c.gtk_tree_view_insert_column_with_attributes(view, -1, "port", c.gtk_cell_renderer_text_new(), "text", @as(c_int, 2), NULL);

    var iter_org: c.GtkTreeIter = undefined;
    var iter_building: c.GtkTreeIter = undefined;
    var iter_clock: c.GtkTreeIter = undefined;

    for (ct.b_orgs) |b_org| {
        c.gtk_tree_store_append(store, &iter_org, null);
        c.gtk_tree_store_set(store, &iter_org, @as(c_int, 0), b_org.org.name.ptr, @as(c_int, -1));

        for (b_org.b_building) |b_building| {
            c.gtk_tree_store_append(store, &iter_building, &iter_org);
            c.gtk_tree_store_set(store, &iter_building, @as(c_int, 0), b_building.building.name.ptr, @as(c_int, -1));

            for (b_building.clocks) |clock| {
                log.debug(
                    \\clock.name: {s}
                    \\       clock.ip  : {s}
                    \\       clock.port: {d}
                , .{ clock.name, clock.ip, clock.port });

                var buf: [8]u8 = undefined;
                const clock_port: [:0]const u8 = std.fmt.bufPrintZ(&buf, "{d}", .{clock.port}) catch "error";

                c.gtk_tree_store_append(store, &iter_clock, &iter_building);
                c.gtk_tree_store_set(
                    store,
                    &iter_clock,
                    @as(c_int, 0),
                    clock.name.ptr,
                    @as(c_int, 1),
                    clock.ip.ptr,
                    @as(c_int, 2),
                    clock_port.ptr,
                    @as(c_int, -1),
                );
            }
        }
    }

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
