const std = @import("std");
const log = std.log;

const c = @import("c.zig").gtk;

const ClocksTree = @import("../../model/ClocksTree.zig");
const App = @import("App.zig");

pub const idx = 1;
pub const label = "Clocks";

const NULL: ?*anyopaque = null;

pub fn create(app: *App) *c.GtkWidget {
    const ct: ClocksTree = app.loadClocksTree() catch |err| {
        log.err("Unable to load ClocksTree: {t}", .{err});
        app.setStatus(.Error);
        app.setCurrentPage(idx);
        return c.gtk_label_new("Unable to load Clocks");
    };
    defer ct.destroy();

    const tree_view: [*c]c.GtkTreeView = @ptrCast(c.gtk_tree_view_new());
    c.gtk_tree_view_set_enable_tree_lines(tree_view, 1);

    const tree_store: [*c]c.GtkTreeStore = c.gtk_tree_store_new(3, c.G_TYPE_STRING, c.G_TYPE_STRING, c.G_TYPE_STRING);
    defer c.g_object_unref(tree_store);

    c.gtk_tree_view_set_model(tree_view, @ptrCast(tree_store));

    // zig fmt: off

    _ = c.gtk_tree_view_insert_column_with_attributes(tree_view,
        -1, "clock", c.gtk_cell_renderer_text_new(), "text", @as(c_int, 0),
    NULL);
    _ = c.gtk_tree_view_insert_column_with_attributes(tree_view,
        -1, "ip", c.gtk_cell_renderer_text_new(), "text", @as(c_int, 1),
    NULL);
    _ = c.gtk_tree_view_insert_column_with_attributes(tree_view,
        -1, "port", c.gtk_cell_renderer_text_new(), "text", @as(c_int, 2),
    NULL);

    var iter_org: c.GtkTreeIter = undefined;
    var iter_building: c.GtkTreeIter = undefined;
    var iter_clock: c.GtkTreeIter = undefined;

    for (ct.b_orgs) |b_org| {
        c.gtk_tree_store_append(tree_store, &iter_org, null);
        c.gtk_tree_store_set(tree_store, &iter_org,
            @as(c_int, 0), b_org.org.name.ptr,
        @as(c_int, -1));

        for (b_org.b_building) |b_building| {
            c.gtk_tree_store_append(tree_store, &iter_building, &iter_org);
            c.gtk_tree_store_set(tree_store, &iter_building,
                @as(c_int, 0), b_building.building.name.ptr,
            @as(c_int, -1));

            for (b_building.clocks) |clock| {
                var buf: [8]u8 = undefined;
                const clock_port: [:0]const u8 = std.fmt.bufPrintZ(&buf, "{d}", .{clock.port}) catch unreachable;

                c.gtk_tree_store_append(tree_store, &iter_clock, &iter_building);
                c.gtk_tree_store_set(tree_store, &iter_clock,
                    @as(c_int, 0), clock.name.ptr, @as(c_int, 1), clock.ip.ptr, @as(c_int, 2), clock_port.ptr,
                @as(c_int, -1));
            }
        }
    }

    c.gtk_tree_view_expand_all(tree_view);

    return @ptrCast(tree_view);
}
