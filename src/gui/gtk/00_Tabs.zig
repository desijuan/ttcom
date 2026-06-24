const std = @import("std");
const log = std.log;

const c = @import("c.zig").gtk;

const App = @import("App.zig");

const TabLog = @import("10_TabLog.zig");
const TabClocks = @import("20_TabClocks.zig");
const TabSettings = @import("30_TabSettings.zig");

pub fn create(app: *App) [*c]c.GtkWidget {
    const notebook: [*c]c.GtkWidget = c.gtk_notebook_new();
    app.notebook = @ptrCast(notebook);

    if (-1 == c.gtk_notebook_insert_page(
        app.notebook,
        TabLog.create(app),
        c.gtk_label_new(TabLog.label),
        TabLog.idx,
    ) or -1 == c.gtk_notebook_insert_page(
        app.notebook,
        TabClocks.create(app),
        c.gtk_label_new(TabClocks.label),
        TabClocks.idx,
    ) or -1 == c.gtk_notebook_insert_page(
        app.notebook,
        TabSettings.create(app),
        c.gtk_label_new(TabSettings.label),
        TabSettings.idx,
    )) {
        app.setStatus(.Error);
        log.err("gtk_notebook_insert_page failed", .{});
        return c.gtk_label_new("Unable to initialize tabs");
    }

    c.gtk_widget_set_vexpand(notebook, 1);

    return notebook;
}
