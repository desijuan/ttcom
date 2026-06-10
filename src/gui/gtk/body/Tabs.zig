const c = @import("../../../c.zig").c;

const Model = @import("../../../model/Model.zig");
const TabLog = @import("tabs/TabLog.zig");
const TabClocks = @import("tabs/TabClocks.zig");
const TabSettings = @import("tabs/TabSettings.zig");

pub fn create(model: *Model) [*c]c.GtkWidget {
    const notebook: [*c]c.GtkWidget = c.gtk_notebook_new();

    append_page(notebook, model, TabLog);
    append_page(notebook, model, TabClocks);
    append_page(notebook, model, TabSettings);

    c.gtk_widget_set_vexpand(notebook, 1);

    return notebook;
}

fn append_page(notebook: [*c]c.GtkWidget, model: *Model, comptime Tab: type) void {
    _ = c.gtk_notebook_append_page(@ptrCast(notebook), Tab.create(model), Tab.create_label());
}
