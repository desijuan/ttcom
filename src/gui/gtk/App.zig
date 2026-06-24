const std = @import("std");
const log = std.log;

const c = @import("c.zig").gtk;

const mem = @import("../../mem.zig");

const Config = @import("../../Config.zig");
const Conn = @import("../../model/db/Conn.zig");

const ClocksTree = @import("../../model/ClocksTree.zig");
const Settings = @import("../../model/db/Settings.zig");

const Notebook = @import("00_Notebook.zig");
const LogView = @import("10_LogView.zig");
const SettingsView = @import("30_SettingsView.zig");
const StatusBar = @import("99_StatusBar.zig");

const App = @This();

cfg: Config,
conn: Conn,
gtk_app: [*c]c.GtkApplication,

notebook: Notebook = .{},
log_view: LogView = .{},
settings_view: SettingsView = .{},
status_bar: StatusBar = .{},

pub const NewAppError = error{OutOfMemory};

pub fn new(cfg: Config, conn: Conn) NewAppError!*const App {
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
    c.gtk_box_pack_start(root_vbox, Notebook.create(app), 1, 1, 0);
    c.gtk_box_pack_end(root_vbox, StatusBar.create(app), 0, 0, 0);
    c.gtk_container_add(@ptrCast(window), @ptrCast(root_vbox));

    c.gtk_widget_show_all(@ptrCast(window));

    app.doAfterShowAll();

    // TODO: Sacar esto
    app.appendSomeLines();
}

fn doAfterShowAll(app: *App) void {
    app.status_bar.updateStatusLabel();
    app.notebook.updateCurrentPage();
}

//
// TODO: Sacar esto
//
fn appendSomeLines(app: App) void {
    var buf: [256]u8 = undefined;
    const db_line: [:0]const u8 = std.fmt.bufPrintZ(&buf, "[INFO] Connected to database: {s}", .{
        app.cfg.db_filename,
    }) catch |err| @errorName(err);

    app.log_view.append("[INFO] Application started");
    app.log_view.append(db_line);
    app.log_view.append("[INFO] Polling interval: 60s");
    app.log_view.append("[WARN] Clock 3 (Cancillería 1 Estacionamiento) last seen 42s ago");
    app.log_view.append("[INFO] Clock 1 (Cancillería 1 Entrada Principal) synced OK");
    app.log_view.append("[INFO] Clock 2 (Cancillería 1 Entrada Lateral) synced OK");
}
