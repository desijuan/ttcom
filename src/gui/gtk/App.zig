const c = @import("../../c.zig").c;

const Model = @import("../../model/Model.zig");
const TabLog = @import("body/tabs/TabLog.zig");
const TabSettings = @import("body/tabs/TabSettings.zig");
const Tabs = @import("body/Tabs.zig");
const StatusBar = @import("body/StatusBar.zig");

pub fn run(model: *Model) c_int {
    const app: [*c]c.GtkApplication = c.gtk_application_new("ar.com.sage.ttcom", c.G_APPLICATION_DEFAULT_FLAGS);
    defer c.g_object_unref(app);
    _ = c.g_signal_connect_data(app, "activate", @ptrCast(&activate), @ptrCast(model), null, 0);
    return c.g_application_run(@ptrCast(app), 0, null);
}

fn activate(app: [*c]c.GtkApplication, data: c.gpointer) callconv(.c) void {
    const model: *Model = @ptrCast(@alignCast(data));

    const window: [*c]c.GtkWidget = c.gtk_application_window_new(app);
    c.gtk_window_set_default_size(@ptrCast(window), 640, 480);
    c.gtk_window_set_position(@ptrCast(window), c.GTK_WIN_POS_CENTER);
    c.gtk_window_set_title(@ptrCast(window), "ttcom");

    const root_vbox = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 0);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(root_vbox)), Tabs.create(model), 1, 1, 0);
    c.gtk_box_pack_end(@as(*c.GtkBox, @ptrCast(root_vbox)), StatusBar.create(model), 0, 0, 0);
    c.gtk_container_add(@as(*c.GtkContainer, @ptrCast(window)), root_vbox);

    c.gtk_widget_show_all(window);
}
