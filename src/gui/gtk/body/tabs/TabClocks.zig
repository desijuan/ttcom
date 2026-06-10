const c = @import("../../../../c.zig").c;

const Model = @import("../../../../model/Model.zig");

pub const label = "Clocks";

pub fn create(_: *Model) *c.GtkWidget {
    const lbl: [*c]c.GtkWidget = c.gtk_label_new("WIP");
    return lbl;
}

pub fn create_label() *c.GtkWidget {
    return c.gtk_label_new(label);
}
