const std = @import("std");
const Allocator = std.mem.Allocator;
const log = std.log;

const c = @import("../../c.zig").c;

const Conn = @import("../../model/db/Conn.zig");
const Model = @import("../../model/Model.zig");
const Config = Model.Config;
const TabLog = @import("body/tabs/TabLog.zig");
const TabSettings = @import("body/tabs/TabSettings.zig");
const Tabs = @import("body/Tabs.zig");
const StatusBar = @import("body/StatusBar.zig");

const Fields = struct {
    log_file: [*c]c.GtkEntry = null,
    push_ip: [*c]c.GtkEntry = null,
    push_port: [*c]c.GtkEntry = null,
    push_freq_s: [*c]c.GtkEntry = null,
    timeout_s: [*c]c.GtkEntry = null,
};

pub const Status = enum {
    Idle,
    Ready,
    Error,

    pub fn tagName(self: Status) [:0]const u8 {
        return @tagName(self);
    }
};

const App = @This();

model: *Model,
conn: Conn,
gtk_app: [*c]c.GtkApplication,
fields: Fields = .{},
status: [*c]c.GtkLabel = null,

pub fn create(a: Allocator, model: *Model, conn: Conn) error{OutOfMemory}!*const App {
    const gtk_app: [*c]c.GtkApplication = c.gtk_application_new("ar.com.sage.ttcom", c.G_APPLICATION_DEFAULT_FLAGS);

    const app: *App = try a.create(App);
    errdefer a.destroy(app);

    app.* = App{ .model = model, .conn = conn, .gtk_app = gtk_app };

    _ = c.g_signal_connect_data(gtk_app, "activate", @ptrCast(&activate), @ptrCast(app), null, 0);

    return app;
}

pub fn destroy(self: *const App, a: Allocator) void {
    a.destroy(self);
}

pub fn run(self: App) c_int {
    defer c.g_object_unref(self.gtk_app);
    return c.g_application_run(@ptrCast(self.gtk_app), 0, null);
}

pub fn saveConfig(self: App) !void {
    const log_file: [:0]const u8 = gtkEntryGetText(self.fields.log_file);
    const push_ip: [:0]const u8 = gtkEntryGetText(self.fields.push_ip);
    const push_port: u16 = std.fmt.parseInt(u16, gtkEntryGetText(self.fields.push_port), 10) catch 0;
    const push_freq_s: u32 = std.fmt.parseInt(u32, gtkEntryGetText(self.fields.push_freq_s), 10) catch 0;
    const timeout_s: u32 = std.fmt.parseInt(u32, gtkEntryGetText(self.fields.timeout_s), 10) catch 0;

    const cfg: Config = .{
        .log_file = log_file,
        .push_ip = push_ip,
        .push_port = push_port,
        .push_freq_s = push_freq_s,
        .timeout_s = timeout_s,
    };

    try self.conn.writeConfig(&cfg);
}

pub fn setStatus(self: App, status: Status) void {
    c.gtk_label_set_text(self.status, status.tagName());
}

fn activate(gtk_app: [*c]c.GtkApplication, data: c.gpointer) callconv(.c) void {
    const app: *App = @ptrCast(@alignCast(data));

    const window: [*c]c.GtkWindow = @ptrCast(c.gtk_application_window_new(gtk_app));
    c.gtk_window_set_default_size(window, 640, 480);
    c.gtk_window_set_position(window, c.GTK_WIN_POS_CENTER);
    c.gtk_window_set_title(window, "ttcom");

    const root_vbox: [*c]c.GtkBox = @ptrCast(c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 0));
    c.gtk_box_pack_start(root_vbox, Tabs.create(app), 1, 1, 0);
    c.gtk_box_pack_end(root_vbox, StatusBar.create(app), 0, 0, 0);
    c.gtk_container_add(@ptrCast(window), @ptrCast(root_vbox));

    c.gtk_widget_show_all(@ptrCast(window));
}

fn gtkEntryGetText(entry: [*c]c.GtkEntry) [:0]const u8 {
    const len = c.gtk_entry_get_text_length(entry);
    return c.gtk_entry_get_text(entry)[0..len :0];
}

fn gtkEntryGetInt(comptime T: type, entry: [*c]c.GtkEnytry) T {
    const len = c.gtk_entry_get_text_length(entry);
    const text: [:0]const u8 = c.gtk_entry_get_text(entry)[0..len :0];
    return std.fmt.parseInt(T, text, 10);
}
