const std = @import("std");
const c = @cImport(@cInclude("gtk/gtk.h"));

var entry_username: *c.GtkWidget = undefined;
var entry_password: *c.GtkWidget = undefined;
var label_status: *c.GtkWidget = undefined;

// ---------------------------------------------------------------------------
// Callbacks
// ---------------------------------------------------------------------------

fn on_login_clicked(_: *c.GtkWidget, _: c.gpointer) callconv(.c) void {
    const user = c.gtk_entry_get_text(@as(*c.GtkEntry, @ptrCast(entry_username)));
    const pass = c.gtk_entry_get_text(@as(*c.GtkEntry, @ptrCast(entry_password)));

    if (c.g_strcmp0(user, "admin") == 0 and c.g_strcmp0(pass, "secret") == 0) {
        c.gtk_label_set_markup(
            @as(*c.GtkLabel, @ptrCast(label_status)),
            "<span foreground='#4CAF50'>✔  Welcome, admin!</span>",
        );
    } else {
        c.gtk_label_set_markup(
            @as(*c.GtkLabel, @ptrCast(label_status)),
            "<span foreground='#F44336'>✘  Invalid credentials.</span>",
        );
    }
}

fn on_cancel_clicked(_: *c.GtkWidget, _: c.gpointer) callconv(.c) void {
    c.gtk_main_quit();
}

fn on_destroy(_: *c.GtkWidget, _: c.gpointer) callconv(.c) void {
    c.gtk_main_quit();
}

// ---------------------------------------------------------------------------
// UI
// ---------------------------------------------------------------------------

fn build_ui() void {
    const window = c.gtk_window_new(c.GTK_WINDOW_TOPLEVEL);
    c.gtk_window_set_title(@as(*c.GtkWindow, @ptrCast(window)), "Login");
    c.gtk_window_set_default_size(@as(*c.GtkWindow, @ptrCast(window)), 360, 260);
    c.gtk_window_set_resizable(@as(*c.GtkWindow, @ptrCast(window)), c.FALSE);
    c.gtk_window_set_position(@as(*c.GtkWindow, @ptrCast(window)), c.GTK_WIN_POS_CENTER);
    c.gtk_container_set_border_width(@as(*c.GtkContainer, @ptrCast(window)), 24);
    _ = c.g_signal_connect_data(window, "destroy", @ptrCast(&on_destroy), null, null, 0);

    // Outer vertical box
    const vbox = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 16);
    c.gtk_container_add(@as(*c.GtkContainer, @ptrCast(window)), vbox);

    // Title
    const title = c.gtk_label_new(null);
    c.gtk_label_set_markup(
        @as(*c.GtkLabel, @ptrCast(title)),
        "<span size='x-large' weight='bold'>Sign In</span>",
    );
    c.gtk_widget_set_halign(title, c.GTK_ALIGN_START);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(vbox)), title, c.FALSE, c.FALSE, 0);

    // Grid
    const grid = c.gtk_grid_new();
    c.gtk_grid_set_row_spacing(@as(*c.GtkGrid, @ptrCast(grid)), 10);
    c.gtk_grid_set_column_spacing(@as(*c.GtkGrid, @ptrCast(grid)), 12);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(vbox)), grid, c.FALSE, c.FALSE, 0);

    // Username
    const lbl_user = c.gtk_label_new("Username");
    c.gtk_widget_set_halign(lbl_user, c.GTK_ALIGN_END);
    c.gtk_grid_attach(@as(*c.GtkGrid, @ptrCast(grid)), lbl_user, 0, 0, 1, 1);

    entry_username = c.gtk_entry_new().?;
    c.gtk_entry_set_placeholder_text(@as(*c.GtkEntry, @ptrCast(entry_username)), "Enter username");
    c.gtk_widget_set_hexpand(entry_username, 0);
    c.gtk_grid_attach(@as(*c.GtkGrid, @ptrCast(grid)), entry_username, 1, 0, 1, 1);

    // Password
    const lbl_pass = c.gtk_label_new("Password");
    c.gtk_widget_set_halign(lbl_pass, c.GTK_ALIGN_END);
    c.gtk_grid_attach(@as(*c.GtkGrid, @ptrCast(grid)), lbl_pass, 0, 1, 1, 1);

    entry_password = c.gtk_entry_new().?;
    c.gtk_entry_set_visibility(@as(*c.GtkEntry, @ptrCast(entry_password)), c.FALSE);
    c.gtk_entry_set_placeholder_text(@as(*c.GtkEntry, @ptrCast(entry_password)), "Enter password");
    c.gtk_widget_set_hexpand(entry_password, 0);
    c.gtk_grid_attach(@as(*c.GtkGrid, @ptrCast(grid)), entry_password, 1, 1, 1, 1);

    // Status label
    label_status = c.gtk_label_new("").?;
    c.gtk_widget_set_halign(label_status, c.GTK_ALIGN_START);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(vbox)), label_status, c.FALSE, c.FALSE, 0);

    // Spacer
    const spacer = c.gtk_label_new("");
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(vbox)), spacer, 0, 0, 0);

    // Buttons
    const hbox = c.gtk_box_new(c.GTK_ORIENTATION_HORIZONTAL, 8);
    c.gtk_widget_set_halign(hbox, c.GTK_ALIGN_END);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(vbox)), hbox, c.FALSE, c.FALSE, 0);

    const btn_cancel = c.gtk_button_new_with_label("Cancel");
    _ = c.g_signal_connect_data(btn_cancel, "clicked", @ptrCast(&on_cancel_clicked), null, null, 0);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(hbox)), btn_cancel, c.FALSE, c.FALSE, 0);

    const btn_login = c.gtk_button_new_with_label("Login");
    _ = c.g_signal_connect_data(btn_login, "clicked", @ptrCast(&on_login_clicked), null, null, 0);
    c.gtk_box_pack_start(@as(*c.GtkBox, @ptrCast(hbox)), btn_login, c.FALSE, c.FALSE, 0);

    c.gtk_widget_show_all(window);
}

pub fn run() void {
    c.gtk_init(null, null);
    build_ui();
    c.gtk_main();
}
