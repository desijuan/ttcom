const std = @import("std");
const log = std.log;

const c = @import("c.zig").gtk;

const mem = @import("../../mem.zig");

const App = @import("App.zig");

const Settings = @import("../../model/db/Settings.zig");

pub const idx = 2;
pub const label = "Settings";

const SettingsView = @This();

entry_log_file: [*c]c.GtkEntry = null,
entry_push_ip: [*c]c.GtkEntry = null,
entry_push_port: [*c]c.GtkEntry = null,
entry_push_freq_s: [*c]c.GtkEntry = null,
entry_timeout_s: [*c]c.GtkEntry = null,

pub fn create(app: *App) [*c]c.GtkWidget {
    const settings: Settings = Settings.read(app.conn) catch |err| {
        log.err("Unable to load Settings: {t}", .{err});
        app.status_bar.setStatus(.Error);
        app.notebook.setCurrentPage(idx);
        return c.gtk_label_new("Unable to load settings");
    };
    defer settings.deinit();

    // vBox
    const vbox: [*c]c.GtkWidget = @ptrCast(c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 0));
    c.gtk_widget_set_margin_bottom(vbox, 6);
    c.gtk_widget_set_margin_start(vbox, 56);
    c.gtk_widget_set_margin_end(vbox, 56);

    // Grid
    const grid: [*c]c.GtkGrid = @ptrCast(c.gtk_grid_new());
    c.gtk_grid_set_column_spacing(grid, 4);
    c.gtk_grid_set_row_spacing(grid, 4);

    // Entries

    const e_log_file: [*c]c.GtkWidget = c.gtk_entry_new();
    const e_push_ip: [*c]c.GtkWidget = c.gtk_entry_new();
    const e_push_port: [*c]c.GtkWidget = c.gtk_entry_new();
    const e_push_freq_s: [*c]c.GtkWidget = c.gtk_entry_new();
    const e_timeout_s: [*c]c.GtkWidget = c.gtk_entry_new();

    c.gtk_widget_set_hexpand(e_log_file, 1);

    app.settings_view = SettingsView{
        .entry_log_file = @ptrCast(e_log_file),
        .entry_push_ip = @ptrCast(e_push_ip),
        .entry_push_port = @ptrCast(e_push_port),
        .entry_push_freq_s = @ptrCast(e_push_freq_s),
        .entry_timeout_s = @ptrCast(e_timeout_s),
    };

    // Labels - left

    const label_log_file = c.gtk_label_new("Log File:");
    c.gtk_widget_set_halign(label_log_file, c.GTK_ALIGN_END);

    const label_push_ip = c.gtk_label_new("Push IP:");
    c.gtk_widget_set_halign(label_push_ip, c.GTK_ALIGN_END);

    const label_push_port = c.gtk_label_new("Push Port:");
    c.gtk_widget_set_halign(label_push_port, c.GTK_ALIGN_END);

    const label_push_freq_s = c.gtk_label_new("Push Frequency:");
    c.gtk_widget_set_halign(label_push_freq_s, c.GTK_ALIGN_END);

    const label_timeout_s = c.gtk_label_new("Timeout:");
    c.gtk_widget_set_halign(label_timeout_s, c.GTK_ALIGN_END);

    // Labels - right

    const label_unit_suffix_freq_s = c.gtk_label_new("seconds");
    c.gtk_widget_set_halign(label_unit_suffix_freq_s, c.GTK_ALIGN_START);

    const label_unit_suffix_timeout_s = c.gtk_label_new("seconds");
    c.gtk_widget_set_halign(label_unit_suffix_timeout_s, c.GTK_ALIGN_START);

    // Browse button
    const btn_browse: [*c]c.GtkWidget = c.gtk_button_new_with_label("Browse");
    _ = c.g_signal_connect_data(btn_browse, "clicked", @ptrCast(&clicked_on_browse), @ptrCast(app), null, 0);
    c.gtk_widget_set_halign(btn_browse, c.GTK_ALIGN_START);

    // Set entries text
    var buf: [12]u8 = undefined;

    c.gtk_entry_set_text(app.settings_view.entry_log_file, settings.log_file);
    c.gtk_entry_set_text(app.settings_view.entry_push_ip, settings.push_ip);
    c.gtk_entry_set_text(
        app.settings_view.entry_push_port,
        std.fmt.bufPrintZ(&buf, "{d}", .{settings.push_port}) catch unreachable,
    );
    c.gtk_entry_set_text(
        app.settings_view.entry_push_freq_s,
        std.fmt.bufPrintZ(&buf, "{d}", .{settings.push_freq_s}) catch unreachable,
    );
    c.gtk_entry_set_text(
        app.settings_view.entry_timeout_s,
        std.fmt.bufPrintZ(&buf, "{d}", .{settings.timeout_s}) catch unreachable,
    );

    // Assemble grid
    // zig fmt: off
    // 1st column
    c.gtk_grid_attach(grid, label_log_file,              0, 0, 1, 1);
    c.gtk_grid_attach(grid, label_push_ip,               0, 1, 1, 1);
    c.gtk_grid_attach(grid, label_push_port,             0, 2, 1, 1);
    c.gtk_grid_attach(grid, label_push_freq_s,           0, 3, 1, 1);
    c.gtk_grid_attach(grid, label_timeout_s,             0, 4, 1, 1);
    // 2nd column
    c.gtk_grid_attach(grid, e_log_file,                  1, 0, 1, 1);
    c.gtk_grid_attach(grid, e_push_ip,                   1, 1, 1, 1);
    c.gtk_grid_attach(grid, e_push_port,                 1, 2, 1, 1);
    c.gtk_grid_attach(grid, e_push_freq_s,               1, 3, 1, 1);
    c.gtk_grid_attach(grid, e_timeout_s,                 1, 4, 1, 1);
    // 3rd column
    c.gtk_grid_attach(grid, btn_browse,                  2, 0, 1, 1);
    c.gtk_grid_attach(grid, label_unit_suffix_freq_s,    2, 3, 1, 1);
    c.gtk_grid_attach(grid, label_unit_suffix_timeout_s, 2, 4, 1, 1);
    // zig fmt: on

    // Save button
    const btn_save: [*c]c.GtkWidget = c.gtk_button_new_with_label("Save");
    _ = c.g_signal_connect_data(btn_save, "clicked", @ptrCast(&clicked_on_save), @ptrCast(app), null, 0);
    c.gtk_widget_set_halign(btn_save, c.GTK_ALIGN_CENTER);
    c.gtk_widget_set_size_request(btn_save, 120, -1);

    // Pack Box
    c.gtk_box_pack_start(@ptrCast(vbox), @ptrCast(grid), 1, 0, 0);
    c.gtk_box_pack_end(@ptrCast(vbox), btn_save, 0, 0, 0);

    return vbox;
}

fn clicked_on_browse(_: [*c]c.GtkButton, _: c.gpointer) callconv(.c) void {
    log.info("Browse", .{});
}

fn clicked_on_save(_: [*c]c.GtkButton, data: c.gpointer) callconv(.c) void {
    const app: *App = @ptrCast(@alignCast(data));

    saveSettings(app) catch |err| {
        app.status_bar.setStatusNow(.Error);
        log.err("Unable to save Settings: {t}", .{err});
        return;
    };

    log.info("Settings saved", .{});
}

const SaveSettingsError = std.fmt.ParseIntError || Settings.WriteError;

fn saveSettings(app: *App) SaveSettingsError!void {
    const settings: Settings = try app.settings_view.getSettings();
    try settings.write(app.conn);
}

fn getSettings(self: SettingsView) std.fmt.ParseIntError!Settings {
    const log_file: [:0]const u8 = gtkEntryGetText(self.entry_log_file);
    const push_ip: [:0]const u8 = gtkEntryGetText(self.entry_push_ip);
    const push_port: u16 = try std.fmt.parseInt(u16, gtkEntryGetText(self.entry_push_port), 10);
    const push_freq_s: u32 = try std.fmt.parseInt(u32, gtkEntryGetText(self.entry_push_freq_s), 10);
    const timeout_s: u32 = try std.fmt.parseInt(u32, gtkEntryGetText(self.entry_timeout_s), 10);

    return Settings{
        .log_file = log_file,
        .push_ip = push_ip,
        .push_port = push_port,
        .push_freq_s = push_freq_s,
        .timeout_s = timeout_s,
    };
}

fn gtkEntryGetText(entry: [*c]c.GtkEntry) [:0]const u8 {
    const len = c.gtk_entry_get_text_length(entry);
    return c.gtk_entry_get_text(entry)[0..len :0];
}
