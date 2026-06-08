const c = @import("../../../c.zig").c;

const TabLog = @import("tabs/TabLog.zig");
const TabClocks = @import("tabs/TabClocks.zig");
const TabSettings = @import("tabs/TabSettings.zig");

pub fn create() [*c]c.GtkWidget {
    const notebook: [*c]c.GtkWidget = c.gtk_notebook_new();

    append_page(notebook, TabLog);
    append_page(notebook, TabClocks);
    append_page(notebook, TabSettings);

    c.gtk_widget_set_vexpand(notebook, 1);

    return notebook;
}

fn append_page(notebook: [*c]c.GtkWidget, comptime Tab: type) void {
    _ = c.gtk_notebook_append_page(@ptrCast(notebook), Tab.create(), Tab.create_label());
}
