const c = @import("../../c.zig").gtk;

const App = @import("App.zig");

pub fn create(app: *App) [*c]c.GtkWidget {
    const status_label: [*c]c.GtkWidget = c.gtk_label_new(App.Status.Ready.tagName());
    c.gtk_widget_set_halign(status_label, c.GTK_ALIGN_START);
    c.gtk_widget_set_margin_start(status_label, 3);
    c.gtk_widget_set_margin_top(status_label, 1);
    c.gtk_widget_set_margin_bottom(status_label, 1);

    app.status = @ptrCast(status_label);

    return status_label;
}
