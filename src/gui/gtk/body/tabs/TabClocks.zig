const c = @import("../../../../c.zig").c;

const App = @import("../../App.zig");

pub const label = "Clocks";

pub fn create(_: *App) *c.GtkWidget {
    const lbl: [*c]c.GtkWidget = c.gtk_label_new("WIP");
    return lbl;
}

pub fn create_label() *c.GtkWidget {
    return c.gtk_label_new(label);
}
