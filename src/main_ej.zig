const std = @import("std");
const log = std.log;

const DB = @import("db.zig");

const c = @import("c.zig").c;

// ------------------------------------------------------------------ //
//  Globals — widgets reachable from callbacks                         //
// ------------------------------------------------------------------ //

var log_view: *c.GtkTextView = undefined;
var log_buffer: *c.GtkTextBuffer = undefined;

var fld_ip: *c.GtkEntry = undefined;
var fld_freq: *c.GtkEntry = undefined;
var fld_dbfile: *c.GtkEntry = undefined;
var fld_timeout: *c.GtkEntry = undefined;

var status_label: *c.GtkWidget = undefined;

// ------------------------------------------------------------------ //
//  Helpers                                                            //
// ------------------------------------------------------------------ //

fn log_append(line: [:0]const u8) void {
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

// ------------------------------------------------------------------ //
//  Callbacks                                                          //
// ------------------------------------------------------------------ //

fn on_destroy(_: *c.GtkWidget, _: c.gpointer) callconv(.c) void {
    log.info("Bye!", .{});
    c.gtk_main_quit();
}

fn on_save_clicked(_: *c.GtkButton, _: c.gpointer) callconv(.c) void {
    const ip = c.gtk_entry_get_text(fld_ip);
    const freq = c.gtk_entry_get_text(fld_freq);
    const db = c.gtk_entry_get_text(fld_dbfile);

    var buf: [256]u8 = undefined;
    const msg = std.fmt.bufPrintZ(
        &buf,
        "[INFO]  Settings saved — IP: {s}  Freq: {s}s  DB: {s}",
        .{ ip, freq, db },
    ) catch return;
    log_append(msg);
    log.info("{s}", .{msg});

    const dialog = c.gtk_message_dialog_new(
        null,
        c.GTK_DIALOG_MODAL,
        c.GTK_MESSAGE_INFO,
        c.GTK_BUTTONS_OK,
        "Settings saved successfully.",
    );
    _ = c.gtk_dialog_run(@as(*c.GtkDialog, @ptrCast(dialog)));
    c.gtk_widget_destroy(dialog);
}

fn on_browse_clicked(_: *c.GtkButton, _: c.gpointer) callconv(.c) void {
    const dialog = c.gtk_file_chooser_dialog_new(
        "Select Database File",
        null,
        c.GTK_FILE_CHOOSER_ACTION_OPEN,
        "_Cancel",
        c.GTK_RESPONSE_CANCEL,
        "_Open",
        c.GTK_RESPONSE_ACCEPT,
        @as(?*anyopaque, null),
    );

    // Filter for SQLite files
    const filter = c.gtk_file_filter_new();
    c.gtk_file_filter_set_name(filter, "SQLite Databases");
    c.gtk_file_filter_add_pattern(filter, "*.db");
    c.gtk_file_filter_add_pattern(filter, "*.sqlite");
    c.gtk_file_filter_add_pattern(filter, "*.sqlite3");
    c.gtk_file_chooser_add_filter(@as(*c.GtkFileChooser, @ptrCast(dialog)), filter);

    if (c.gtk_dialog_run(@as(*c.GtkDialog, @ptrCast(dialog))) == c.GTK_RESPONSE_ACCEPT) {
        const path = c.gtk_file_chooser_get_filename(@as(*c.GtkFileChooser, @ptrCast(dialog)));
        defer c.g_free(path);
        if (path != null) c.gtk_entry_set_text(fld_dbfile, path);
    }
    c.gtk_widget_destroy(dialog);
}

// ------------------------------------------------------------------ //
//  Tab 1 — Information                                                //
// ------------------------------------------------------------------ //

fn create_tab_information() *c.GtkWidget {
    // Text view inside a scrolled window
    const scroll = c.gtk_scrolled_window_new(null, null);
    c.gtk_scrolled_window_set_policy(
        @as(*c.GtkScrolledWindow, @ptrCast(scroll)),
        c.GTK_POLICY_AUTOMATIC,
        c.GTK_POLICY_AUTOMATIC,
    );

    log_buffer = c.gtk_text_buffer_new(null);
    log_view = @as(*c.GtkTextView, @ptrCast(c.gtk_text_view_new_with_buffer(log_buffer)));
    c.gtk_text_view_set_editable(log_view, 0);
    c.gtk_text_view_set_cursor_visible(log_view, 0);
    c.gtk_text_view_set_wrap_mode(log_view, c.GTK_WRAP_WORD_CHAR);
    c.gtk_text_view_set_top_margin(log_view, 3);
    c.gtk_text_view_set_left_margin(log_view, 3);

    // Set Monospace
    c.gtk_text_view_set_monospace(log_view, 1);

    c.gtk_container_add(@as(*c.GtkContainer, @ptrCast(scroll)), @ptrCast(log_view));
    c.gtk_widget_set_vexpand(scroll, 0);
    c.gtk_widget_set_hexpand(scroll, 0);

    // Seed some log lines
    log_append("[INFO]  Application started");
    log_append("[INFO]  Connected to database: clocks.db");
    log_append("[INFO]  Polling interval: 5s");
    log_append("[WARN]  Clock 3 (Tokyo) last seen 42s ago");
    log_append("[INFO]  Clock 1 (New York) synced OK");
    log_append("[INFO]  Clock 2 (London) synced OK");

    return scroll;
}

// ------------------------------------------------------------------ //
//  Tab 2 — Settings                                                   //
// ------------------------------------------------------------------ //

fn row(label_text: [:0]const u8, field: *c.GtkWidget, extra: ?*c.GtkWidget) *c.GtkWidget {
    const hbox = c.gtk_box_new(c.GTK_ORIENTATION_HORIZONTAL, 6);

    const lbl = c.gtk_label_new(label_text);
    c.gtk_widget_set_size_request(lbl, 130, -1);
    c.gtk_label_set_xalign(@ptrCast(lbl), 1.0); // right-align

    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(hbox)), lbl, 0, 0, 0);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(hbox)), field, 0, 0, 0);
    if (extra) |widget| {
        c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(hbox)), widget, 0, 0, 0);
    }

    return hbox;
}

fn create_tab_settings() *c.GtkWidget {
    // Fields
    fld_ip = @as(*c.GtkEntry, @ptrCast(c.gtk_entry_new()));
    c.gtk_entry_set_text(fld_ip, "192.168.1.100");

    fld_freq = @ptrCast(c.gtk_entry_new());
    c.gtk_entry_set_text(fld_freq, "5");
    c.gtk_widget_set_size_request(@ptrCast(fld_freq), 80, -1);

    fld_dbfile = @ptrCast(c.gtk_entry_new());
    c.gtk_entry_set_text(fld_dbfile, "clocks.db");

    fld_timeout = @ptrCast(c.gtk_entry_new());
    c.gtk_entry_set_text(fld_timeout, "30");
    c.gtk_widget_set_size_request(@ptrCast(fld_timeout), 80, -1);

    // Browse button
    const btn_browse = c.gtk_button_new_with_label("Browse…");
    _ = c.g_signal_connect_data(btn_browse, "clicked", @ptrCast(&on_browse_clicked), null, null, 0);

    // Freq row: entry + unit label
    const freq_box = c.gtk_box_new(c.GTK_ORIENTATION_HORIZONTAL, 6);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(freq_box)), @ptrCast(fld_freq), 0, 0, 0);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(freq_box)), c.gtk_label_new("seconds"), 0, 0, 0);

    // Timeout row: entry + unit label
    const timeout_box = c.gtk_box_new(c.GTK_ORIENTATION_HORIZONTAL, 6);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(timeout_box)), @ptrCast(fld_timeout), 0, 0, 0);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(timeout_box)), c.gtk_label_new("seconds"), 0, 0, 0);

    // Save button row
    const btn_save = c.gtk_button_new_with_label("Save");
    c.gtk_widget_set_halign(btn_save, c.GTK_ALIGN_END);
    _ = c.g_signal_connect_data(btn_save, "clicked", @ptrCast(&on_save_clicked), null, null, 0);

    // Inner vbox
    const inner_vbox = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 0);
    c.gtk_container_set_border_width(@as(*c.GtkContainer, @ptrCast(inner_vbox)), 12);

    c.gtk_box_pack_start(@ptrCast(inner_vbox), row("Push IP:", @ptrCast(fld_ip), null), 0, 0, 0);
    c.gtk_box_pack_start(@ptrCast(inner_vbox), row("Push Frequency:", freq_box, null), 0, 0, 0);
    c.gtk_box_pack_start(@ptrCast(inner_vbox), row("Database File:", @ptrCast(fld_dbfile), btn_browse), 0, 0, 0);
    c.gtk_box_pack_start(@ptrCast(inner_vbox), row("Timeout:", timeout_box, null), 0, 0, 0);

    c.gtk_box_pack_end(@ptrCast(inner_vbox), btn_save, 0, 0, 0);

    // Frame
    const frame = c.gtk_frame_new("Settings");
    c.gtk_container_add(@as(*c.GtkContainer, @ptrCast(frame)), inner_vbox);

    // Outer vbox with padding + fill at bottom
    const outer_vbox = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 0);
    c.gtk_container_set_border_width(@ptrCast(outer_vbox), 5);
    c.gtk_box_pack_start(@ptrCast(outer_vbox), frame, 1, 1, 0);

    return outer_vbox;
}

// ------------------------------------------------------------------ //
//  Main                                                               //
// ------------------------------------------------------------------ //

pub fn main() !void {
    const seed: u64 = @intCast(std.time.milliTimestamp());
    var prng = std.Random.DefaultPrng.init(seed);

    var db_p: ?*DB.sqlite3 = null;
    const db = DB{
        .file_name = "db.sqlite",
        .db_p = &db_p,
        .random = prng.random(),
    };
    try db.open();
    defer db.close() catch |err| {
        std.log.err("{}", .{err});
    };

    _ = c.gtk_init(null, null);

    // Window
    const window: [*c]c.GtkWidget = c.gtk_window_new(c.GTK_WINDOW_TOPLEVEL);
    c.gtk_window_set_title(@ptrCast(window), "Sage - ttcom");
    c.gtk_window_set_default_size(@ptrCast(window), 640, 480);
    c.gtk_window_set_position(@ptrCast(window), c.GTK_WIN_POS_CENTER);
    _ = c.g_signal_connect_data(window, "destroy", @ptrCast(&on_destroy), null, null, 0);

    // Notebook (tabs)
    const notebook: [*c]c.GtkWidget = c.gtk_notebook_new();
    _ = c.gtk_notebook_append_page(
        @ptrCast(notebook),
        create_tab_information(),
        c.gtk_label_new("Information"),
    );
    _ = c.gtk_notebook_append_page(
        @ptrCast(notebook),
        create_tab_settings(),
        c.gtk_label_new("Settings"),
    );
    c.gtk_widget_set_vexpand(notebook, 0);

    // Status label
    status_label = c.gtk_label_new("Ready");
    c.gtk_widget_set_halign(status_label, c.GTK_ALIGN_START);
    c.gtk_widget_set_margin_start(status_label, 3);
    c.gtk_widget_set_margin_top(status_label, 1);
    c.gtk_widget_set_margin_bottom(status_label, 1);

    // Root layout
    const root_vbox = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 0);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(root_vbox)), notebook, 1, 1, 0);
    c.gtk_box_pack_end(@as(*c.GtkBox, @ptrCast(root_vbox)), status_label, 0, 0, 0);
    c.gtk_container_add(@as(*c.GtkContainer, @ptrCast(window)), root_vbox);

    c.gtk_widget_show_all(window);
    c.gtk_main();
}
