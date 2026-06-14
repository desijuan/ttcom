const std = @import("std");
const log = std.log;

const c = @import("../.././../../c.zig").c;

const App = @import("../../App.zig");
const Config = @import("../../../../model/db/Conn.zig").Config;

pub const label = "Settings";

const w_field = 130;

fn row(label_text: [:0]const u8, field: [*c]c.GtkWidget, extra: ?[*c]c.GtkWidget) *c.GtkWidget {
    const hbox = c.gtk_box_new(c.GTK_ORIENTATION_HORIZONTAL, 6);

    const lbl = c.gtk_label_new(label_text);
    c.gtk_widget_set_size_request(lbl, w_field, -1);
    c.gtk_label_set_xalign(@ptrCast(lbl), 1.0); // right-align

    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(hbox)), lbl, 0, 0, 0);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(hbox)), field, 0, 0, 0);
    if (extra) |widget| {
        c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(hbox)), widget, 0, 0, 0);
    }

    return hbox;
}

pub fn create(app: *App) [*c]c.GtkWidget {
    var buf: [32:0]u8 = undefined;

    const cfg: *Config = app.readConfig() catch @panic("TODO: Handle this error");
    defer cfg.destroy(app.a);

    app.fields.log_file = @ptrCast(c.gtk_entry_new());
    c.gtk_entry_set_text(app.fields.log_file, cfg.log_file);

    app.fields.push_ip = @ptrCast(c.gtk_entry_new());
    c.gtk_entry_set_text(app.fields.push_ip, cfg.push_ip);

    app.fields.push_port = @ptrCast(c.gtk_entry_new());
    c.gtk_entry_set_text(
        app.fields.push_port,
        std.fmt.bufPrintZ(&buf, "{d}", .{cfg.push_port}) catch @panic("OOM"),
    );

    app.fields.push_freq_s = @ptrCast(c.gtk_entry_new());
    c.gtk_entry_set_text(
        app.fields.push_freq_s,
        std.fmt.bufPrintZ(&buf, "{d}", .{cfg.push_freq_s}) catch @panic("OOM"),
    );
    c.gtk_widget_set_size_request(@ptrCast(app.fields.push_freq_s), w_field, -1);

    app.fields.timeout_s = @ptrCast(c.gtk_entry_new());
    c.gtk_entry_set_text(
        app.fields.timeout_s,
        std.fmt.bufPrintZ(&buf, "{d}", .{cfg.timeout_s}) catch @panic("OOM"),
    );
    c.gtk_widget_set_size_request(@ptrCast(app.fields.timeout_s), w_field, -1);

    // Browse button
    const btn_browse = c.gtk_button_new_with_label("Browse…");
    c.gtk_widget_set_size_request(@ptrCast(btn_browse), w_field, -1);
    _ = c.g_signal_connect_data(btn_browse, "clicked", @ptrCast(&clicked_on_browse), @ptrCast(app), null, 0);

    // Save button
    const btn_save = c.gtk_button_new_with_label("Save");
    c.gtk_widget_set_size_request(@ptrCast(btn_save), w_field, -1);
    c.gtk_widget_set_halign(btn_save, c.GTK_ALIGN_END);
    _ = c.g_signal_connect_data(btn_save, "clicked", @ptrCast(&clicked_on_save), @ptrCast(app), null, 0);

    // Inner vbox
    const vbox = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 3);

    c.gtk_widget_set_margin_start(vbox, 45);
    c.gtk_widget_set_margin_end(vbox, 45);
    c.gtk_widget_set_margin_top(vbox, 60);
    c.gtk_widget_set_margin_bottom(vbox, 45);

    c.gtk_box_pack_start(@ptrCast(vbox), row("Log File:", @ptrCast(app.fields.log_file), btn_browse), 0, 0, 0);
    c.gtk_box_pack_start(@ptrCast(vbox), row("Push IP:", @ptrCast(app.fields.push_ip), null), 0, 0, 0);
    c.gtk_box_pack_start(@ptrCast(vbox), row("Push port:", @ptrCast(app.fields.push_port), null), 0, 0, 0);
    c.gtk_box_pack_start(@ptrCast(vbox), row("Push Frequency:", @ptrCast(app.fields.push_freq_s), c.gtk_label_new("seconds")), 0, 0, 0);
    c.gtk_box_pack_start(@ptrCast(vbox), row("Timeout:", @ptrCast(app.fields.timeout_s), c.gtk_label_new("seconds")), 0, 0, 0);

    c.gtk_box_pack_end(@ptrCast(vbox), btn_save, 0, 0, 0);

    return vbox;
}

pub fn create_label() *c.GtkWidget {
    return c.gtk_label_new(label);
}

fn clicked_on_browse(_: [*c]c.GtkButton, _: c.gpointer) callconv(.c) void {
    log.info("Browse", .{});
}

fn clicked_on_save(_: [*c]c.GtkButton, data: c.gpointer) callconv(.c) void {
    const app: *App = @ptrCast(@alignCast(data));
    app.saveConfig() catch |err| {
        app.setStatus(.Error);
        log.err("{t}", .{err});
        return;
    };
    log.info("Config saved", .{});
}
