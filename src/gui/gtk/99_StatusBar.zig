const c = @import("c.zig").gtk;

const App = @import("App.zig");

pub const Status = enum { Loading, Ready, Error };

const StatusBar = @This();

status_label: [*c]c.GtkLabel = null,
status: Status = .Ready,

pub fn create(app: *App) [*c]c.GtkWidget {
    const status_label: [*c]c.GtkWidget = c.gtk_label_new(@tagName(Status.Loading));
    c.gtk_widget_set_halign(status_label, c.GTK_ALIGN_START);
    c.gtk_widget_set_margin_start(status_label, 3);
    c.gtk_widget_set_margin_top(status_label, 1);
    c.gtk_widget_set_margin_bottom(status_label, 1);

    app.status_bar.status_label = @ptrCast(status_label);

    return status_label;
}

pub fn setStatus(self: *StatusBar, status: Status) void {
    self.status = status;
}

pub fn updateStatusLabel(self: StatusBar) void {
    c.gtk_label_set_text(self.status_label, @tagName(self.status));
}

pub fn setStatusNow(self: *StatusBar, status: Status) void {
    self.setStatus(status);
    self.updateStatusLabel();
}
