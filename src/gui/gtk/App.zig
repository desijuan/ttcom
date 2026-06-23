const std = @import("std");
const log = std.log;

const c = @import("c.zig").gtk;

const mem = @import("../../mem.zig");

const Conn = @import("../../model/db/Conn.zig");
const Settings = @import("../../model/db/Settings.zig");
const Config = @import("../../Config.zig");
const ClocksTree = @import("../../model/ClocksTree.zig");

const Tabs = @import("00_Tabs.zig");
const StatusBar = @import("99_StatusBar.zig");

const SettingsEntries = struct {
    log_file: [*c]c.GtkEntry = null,
    push_ip: [*c]c.GtkEntry = null,
    push_port: [*c]c.GtkEntry = null,
    push_freq_s: [*c]c.GtkEntry = null,
    timeout_s: [*c]c.GtkEntry = null,
};

pub const Status = enum {
    Loading,
    Ready,
    Error,

    pub fn tagName(self: Status) [:0]const u8 {
        return @tagName(self);
    }
};

const App = @This();

cfg: Config,
conn: Conn,
gtk_app: [*c]c.GtkApplication,
status: Status = .Ready,
current_page: c_int = -1,
notebook: [*c]c.GtkNotebook = null,
settings_entries: SettingsEntries = .{},
status_label: [*c]c.GtkLabel = null,

pub const CreateError = error{OutOfMemory};

pub fn new(cfg: Config, conn: Conn) CreateError!*const App {
    const gtk_app: [*c]c.GtkApplication = c.gtk_application_new("ar.com.sage.ttcom", c.G_APPLICATION_DEFAULT_FLAGS);

    const app: *App = try mem.a.create(App);
    errdefer mem.a.destroy(app);

    app.* = App{ .cfg = cfg, .conn = conn, .gtk_app = gtk_app };

    _ = c.g_signal_connect_data(gtk_app, "activate", @ptrCast(&activate), @ptrCast(app), null, 0);

    return app;
}

pub fn destroy(self: *const App) void {
    c.g_object_unref(self.gtk_app);
    mem.a.destroy(self);
}

pub fn run(self: App) c_int {
    return c.g_application_run(@ptrCast(self.gtk_app), 0, null);
}

fn activate(gtk_app: [*c]c.GtkApplication, data: c.gpointer) callconv(.c) void {
    const app: *App = @ptrCast(@alignCast(data));

    const window: [*c]c.GtkWindow = @ptrCast(c.gtk_application_window_new(gtk_app));
    c.gtk_window_set_default_size(window, 640, 480);
    c.gtk_window_set_position(window, c.GTK_WIN_POS_CENTER);
    c.gtk_window_set_title(window, "ttcom");

    const root_vbox: [*c]c.GtkBox = @ptrCast(c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 0));
    c.gtk_box_pack_end(root_vbox, StatusBar.create(app), 0, 0, 0);
    c.gtk_box_pack_start(root_vbox, Tabs.create(app), 1, 1, 0);
    c.gtk_container_add(@ptrCast(window), @ptrCast(root_vbox));

    c.gtk_widget_show_all(@ptrCast(window));

    app.updateStatusLabel();
    app.updateCurrentPage();
}

pub fn setCurrentPage(self: *App, n: c_int) void {
    self.current_page = n;
}

fn updateCurrentPage(self: *App) void {
    if (self.current_page >= 0) {
        c.gtk_notebook_set_current_page(self.notebook, self.current_page);
        self.current_page = -1;
    }
}

pub fn setStatus(self: *App, status: Status) void {
    self.status = status;
}

fn updateStatusLabel(self: App) void {
    c.gtk_label_set_text(self.status_label, self.status.tagName());
}

pub const LoadClocksTreeError = ClocksTree.ReadError;

pub fn loadClocksTree(self: App) LoadClocksTreeError!ClocksTree {
    return ClocksTree.read(self.conn);
}

pub const LoadSettingsError = Settings.ReadError;

pub fn loadSettings(self: App) LoadSettingsError!*const Settings {
    return Settings.read(self.conn);
}

pub const SaveSettingsError = std.fmt.ParseIntError || Settings.WriteError;

pub fn saveSettings(self: App) SaveSettingsError!void {
    const log_file: [:0]const u8 = gtkEntryGetText(self.settings_entries.log_file);
    const push_ip: [:0]const u8 = gtkEntryGetText(self.settings_entries.push_ip);
    const push_port: u16 = try std.fmt.parseInt(u16, gtkEntryGetText(self.settings_entries.push_port), 10);
    const push_freq_s: u32 = try std.fmt.parseInt(u32, gtkEntryGetText(self.settings_entries.push_freq_s), 10);
    const timeout_s: u32 = try std.fmt.parseInt(u32, gtkEntryGetText(self.settings_entries.timeout_s), 10);

    const settings: Settings = .{
        .log_file = log_file,
        .push_ip = push_ip,
        .push_port = push_port,
        .push_freq_s = push_freq_s,
        .timeout_s = timeout_s,
    };

    try settings.write(self.conn);
}

// --- Helpers ---

fn gtkEntryGetText(entry: [*c]c.GtkEntry) [:0]const u8 {
    const len = c.gtk_entry_get_text_length(entry);
    return c.gtk_entry_get_text(entry)[0..len :0];
}
