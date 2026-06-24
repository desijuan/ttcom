const std = @import("std");
const log = std.log;

const c = @import("c.zig").gtk;

const App = @import("App.zig");

pub const idx = 0;
pub const label = "Log";

const LogView = @This();

text_view: [*c]c.GtkTextView = null,

pub fn create(app: *App) *c.GtkWidget {
    const text_view: [*c]c.GtkWidget = c.gtk_text_view_new();
    app.log_view.text_view = @ptrCast(text_view);

    c.gtk_text_view_set_editable(app.log_view.text_view, 0);
    c.gtk_text_view_set_cursor_visible(app.log_view.text_view, 0);
    c.gtk_text_view_set_top_margin(app.log_view.text_view, 3);
    c.gtk_text_view_set_left_margin(app.log_view.text_view, 3);
    c.gtk_text_view_set_monospace(app.log_view.text_view, 1);

    const scrolled_window: [*c]c.GtkWidget = c.gtk_scrolled_window_new(null, null);

    c.gtk_widget_set_vexpand(scrolled_window, 1);
    c.gtk_widget_set_valign(scrolled_window, c.GTK_ALIGN_FILL);

    c.gtk_scrolled_window_set_policy(@ptrCast(scrolled_window), c.GTK_POLICY_AUTOMATIC, c.GTK_POLICY_AUTOMATIC);

    c.gtk_container_add(@ptrCast(scrolled_window), text_view);

    return scrolled_window;
}

pub fn append(self: LogView, line: [:0]const u8) void {
    const text_buffer: [*c]c.GtkTextBuffer = c.gtk_text_view_get_buffer(self.text_view);
    var iter: c.GtkTextIter = undefined;
    c.gtk_text_buffer_get_end_iter(text_buffer, &iter);
    if (0 < c.gtk_text_buffer_get_char_count(text_buffer)) {
        c.gtk_text_buffer_insert(text_buffer, &iter, "\n", 1);
    }
    c.gtk_text_buffer_insert(text_buffer, &iter, line, @intCast(line.len));
}
