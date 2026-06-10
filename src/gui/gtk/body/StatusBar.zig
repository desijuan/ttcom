const c = @import("../../../c.zig").c;

const Model = @import("../../../model/Model.zig");

pub fn create(model: *Model) [*c]c.GtkWidget {
    const status_label: [*c]c.GtkWidget = c.gtk_label_new(model.status.tagName());
    c.gtk_widget_set_halign(status_label, c.GTK_ALIGN_START);
    c.gtk_widget_set_margin_start(status_label, 3);
    c.gtk_widget_set_margin_top(status_label, 1);
    c.gtk_widget_set_margin_bottom(status_label, 1);

    return status_label;
}
