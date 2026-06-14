const c = @import("../../../../c.zig").c;

const cfg = @import("../../../../config.zig");
const App = @import("../../App.zig");

pub const label = "Log";

fn log_append(log_buffer: [*c]c.GtkTextBuffer, log_view: [*c]c.GtkTextView, line: [:0]const u8) void {
    var iter: c.GtkTextIter = undefined;
    c.gtk_text_buffer_get_end_iter(log_buffer, &iter);
    const has_text = c.gtk_text_buffer_get_char_count(log_buffer) > 0;
    if (has_text) {
        c.gtk_text_buffer_insert(log_buffer, &iter, "\n", -1);
        c.gtk_text_buffer_get_end_iter(log_buffer, &iter);
    }
    c.gtk_text_buffer_insert(log_buffer, &iter, line, -1);
    // Scroll to bottom
    c.gtk_text_buffer_get_end_iter(log_buffer, &iter);
    const mark = c.gtk_text_buffer_create_mark(log_buffer, null, &iter, 0);
    c.gtk_text_view_scroll_mark_onscreen(@as(*c.GtkTextView, log_view), mark);
}

pub fn create(_: *App) *c.GtkWidget {
    // Text view inside a scrolled window
    const scroll: [*c]c.GtkWidget = c.gtk_scrolled_window_new(null, null);
    c.gtk_scrolled_window_set_policy(
        @ptrCast(scroll),
        c.GTK_POLICY_AUTOMATIC,
        c.GTK_POLICY_AUTOMATIC,
    );

    const log_buffer: [*c]c.GtkTextBuffer = c.gtk_text_buffer_new(null);
    const log_view: [*c]c.GtkTextView = @ptrCast(c.gtk_text_view_new_with_buffer(log_buffer));
    c.gtk_text_view_set_editable(log_view, 0);
    c.gtk_text_view_set_cursor_visible(log_view, 0);
    c.gtk_text_view_set_wrap_mode(log_view, c.GTK_WRAP_WORD_CHAR);
    c.gtk_text_view_set_top_margin(log_view, 3);
    c.gtk_text_view_set_left_margin(log_view, 3);
    c.gtk_text_view_set_monospace(log_view, 1);

    log_append(log_buffer, log_view, "[INFO] Application started");
    log_append(log_buffer, log_view, "[INFO] Connected to database: " ++ cfg.db_name);
    log_append(log_buffer, log_view, "[INFO] Polling interval: 5s");
    log_append(log_buffer, log_view, "[WARN] Clock 3 (Tokyo) last seen 42s ago");
    log_append(log_buffer, log_view, "[INFO] Clock 1 (New York) synced OK");
    log_append(log_buffer, log_view, "[INFO] Clock 2 (London) synced OK");

    c.gtk_container_add(@ptrCast(scroll), @ptrCast(log_view));
    c.gtk_widget_set_vexpand(scroll, 0);
    c.gtk_widget_set_hexpand(scroll, 0);

    return scroll;
}

pub fn create_label() *c.GtkWidget {
    return c.gtk_label_new(label);
}
