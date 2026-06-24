const std = @import("std");

const c = @import("c.zig").gtk;

const App = @import("App.zig");

pub const idx = 0;
pub const label = "Log";

pub fn create(app: *App) *c.GtkWidget {
    const scrolled_window: [*c]c.GtkWidget = c.gtk_scrolled_window_new(null, null);
    c.gtk_scrolled_window_set_policy(@ptrCast(scrolled_window), c.GTK_POLICY_AUTOMATIC, c.GTK_POLICY_AUTOMATIC);

    const log_text_view: [*c]c.GtkWidget = c.gtk_text_view_new();
    app.log_text_view = @ptrCast(log_text_view);

    c.gtk_text_view_set_editable(app.log_text_view, 0);
    c.gtk_text_view_set_cursor_visible(app.log_text_view, 0);
    c.gtk_text_view_set_wrap_mode(app.log_text_view, c.GTK_WRAP_WORD);
    c.gtk_text_view_set_top_margin(app.log_text_view, 3);
    c.gtk_text_view_set_left_margin(app.log_text_view, 3);
    c.gtk_text_view_set_monospace(app.log_text_view, 1);

    c.gtk_container_add(@ptrCast(scrolled_window), log_text_view);

    return scrolled_window;
}
