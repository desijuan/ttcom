const c = @import("../../c.zig").c;

fn btn_ok_handler(_: [*c]c.GtkButton, _: c.gpointer) callconv(.c) void {
    c.g_print("Ok\n");
}

fn btn_cancel_handler(_: [*c]c.GtkButton, _: c.gpointer) callconv(.c) void {
    c.g_print("Cancelar\n");
}

fn activate(app: [*c]c.GtkApplication, _: c.gpointer) callconv(.c) void {
    const window: [*c]c.GtkWidget = c.gtk_application_window_new(app);
    c.gtk_window_set_default_size(@ptrCast(window), 640, 480);
    c.gtk_window_set_position(@ptrCast(window), c.GTK_WIN_POS_CENTER);
    c.gtk_window_set_title(@ptrCast(window), "sage ttcom");

    const vbox: [*c]c.GtkWidget = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 5);
    c.gtk_widget_set_margin_top(vbox, 6);
    c.gtk_widget_set_margin_bottom(vbox, 6);
    c.gtk_widget_set_margin_start(vbox, 6);
    c.gtk_widget_set_margin_end(vbox, 6);
    c.gtk_container_add(@ptrCast(window), vbox);

    const lbl = c.gtk_label_new("Está seguro?");
    c.gtk_box_pack_start(@ptrCast(vbox), lbl, 1, 0, 0);

    const hbox: [*c]c.GtkWidget = c.gtk_box_new(c.GTK_ORIENTATION_HORIZONTAL, 5);
    c.gtk_box_set_homogeneous(@ptrCast(hbox), 1);

    const btn_ok: [*c]c.GtkWidget = c.gtk_button_new_with_label("Ok");
    const btn_cancel: [*c]c.GtkWidget = c.gtk_button_new_with_label("Cancelar");

    _ = c.g_signal_connect_data(btn_ok, "clicked", @ptrCast(&btn_ok_handler), null, null, 0);
    _ = c.g_signal_connect_data(btn_cancel, "clicked", @ptrCast(&btn_cancel_handler), null, null, 0);

    c.gtk_box_pack_start(@ptrCast(hbox), btn_ok, 1, 1, 0);
    c.gtk_box_pack_start(@ptrCast(hbox), btn_cancel, 1, 1, 0);

    c.gtk_box_pack_end(@ptrCast(vbox), hbox, 0, 0, 0);

    c.gtk_widget_show_all(window);
}

pub fn run() c_int {
    const app: [*c]c.GtkApplication = c.gtk_application_new("ar.com.sage", c.G_APPLICATION_DEFAULT_FLAGS);
    defer c.g_object_unref(app);

    _ = c.g_signal_connect_data(app, "activate", @ptrCast(&activate), null, null, 0);

    return c.g_application_run(@ptrCast(app), 0, null);
}
