const c = @import("../../c.zig").gtk;

const App = @import("App.zig");

const TabLog = @import("10_TabLog.zig");
const TabClocks = @import("20_TabClocks.zig");
const TabSettings = @import("30_TabSettings.zig");

pub fn create(app: *App) [*c]c.GtkWidget {
    const notebook: [*c]c.GtkNotebook = @ptrCast(c.gtk_notebook_new());

    n_append_page(notebook, app, TabLog);
    n_append_page(notebook, app, TabClocks);
    n_append_page(notebook, app, TabSettings);

    c.gtk_widget_set_vexpand(@ptrCast(notebook), 1);

    return @ptrCast(notebook);
}

fn n_append_page(notebook: [*c]c.GtkNotebook, app: *App, comptime Tab: type) void {
    _ = c.gtk_notebook_append_page(notebook, Tab.create(app), Tab.create_label());
}
