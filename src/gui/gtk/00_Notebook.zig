const std = @import("std");
const log = std.log;

const c = @import("c.zig").gtk;

const App = @import("App.zig");

const LogView = @import("10_LogView.zig");
const ClocksView = @import("20_ClocksView.zig");
const SettingsView = @import("30_SettingsView.zig");

pub const Notebook = @This();

current_page: c_int = -1,
gtk_notebook: [*c]c.GtkNotebook = null,

pub fn create(app: *App) [*c]c.GtkWidget {
    const notebook: [*c]c.GtkWidget = c.gtk_notebook_new();
    app.notebook.gtk_notebook = @ptrCast(notebook);

    if (-1 == c.gtk_notebook_insert_page(
        app.notebook.gtk_notebook,
        LogView.create(app),
        c.gtk_label_new(LogView.label),
        LogView.idx,
    ) or -1 == c.gtk_notebook_insert_page(
        app.notebook.gtk_notebook,
        ClocksView.create(app),
        c.gtk_label_new(ClocksView.label),
        ClocksView.idx,
    ) or -1 == c.gtk_notebook_insert_page(
        app.notebook.gtk_notebook,
        SettingsView.create(app),
        c.gtk_label_new(SettingsView.label),
        SettingsView.idx,
    )) {
        app.status_bar.setStatus(.Error);
        log.err("gtk_notebook_insert_page failed", .{});
        return c.gtk_label_new("Unable to initialize tabs");
    }

    return notebook;
}

pub fn setCurrentPage(self: *Notebook, n: c_int) void {
    self.current_page = n;
}

pub fn updateCurrentPage(self: *Notebook) void {
    if (self.current_page < 0) return;

    c.gtk_notebook_set_current_page(self.gtk_notebook, self.current_page);
    self.current_page = -1;
}

pub fn setCurrentPageNow(self: *Notebook, n: c_int) void {
    c.gtk_notebook_set_current_page(self.gtk_notebook, n);
    self.current_page = -1;
}
