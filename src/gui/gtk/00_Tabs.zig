const std = @import("std");
const log = std.log;

const c = @import("c.zig").gtk;

const App = @import("App.zig");

const TabLog = @import("10_TabLog.zig");
const TabClocks = @import("20_TabClocks.zig");
const TabSettings = @import("30_TabSettings.zig");

pub fn create(app: *App) [*c]c.GtkWidget {
    const notebook: [*c]c.GtkNotebook = @ptrCast(c.gtk_notebook_new());
    app.notebook = notebook;

    if (-1 == c.gtk_notebook_insert_page(notebook, TabLog.create(app), TabLog.createLabel(), TabLog.idx) or
        -1 == c.gtk_notebook_insert_page(notebook, TabClocks.create(app), TabClocks.createLabel(), TabClocks.idx) or
        -1 == c.gtk_notebook_insert_page(notebook, TabSettings.create(app), TabSettings.createLabel(), TabSettings.idx))
    {
        app.setStatus(.Error);
        log.err("gtk_notebook_insert_page failed", .{});
        return c.gtk_label_new("Unable to initialize tabs");
    }

    c.gtk_widget_set_vexpand(@ptrCast(notebook), 1);

    return @ptrCast(notebook);
}
