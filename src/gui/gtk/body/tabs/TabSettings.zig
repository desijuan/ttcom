const c = @import("../.././../../c.zig").c;

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

pub fn create() [*c]c.GtkWidget {

    // Fields
    const fld_ip: [*c]c.GtkEntry = @ptrCast(c.gtk_entry_new());
    c.gtk_entry_set_text(fld_ip, "192.168.1.100");

    const fld_freq: [*c]c.GtkEntry = @ptrCast(c.gtk_entry_new());
    c.gtk_entry_set_text(fld_freq, "5");
    c.gtk_widget_set_size_request(@ptrCast(fld_freq), w_field, -1);

    const fld_dbfile: [*c]c.GtkEntry = @ptrCast(c.gtk_entry_new());
    c.gtk_entry_set_text(fld_dbfile, "clocks.db");

    const fld_timeout: [*c]c.GtkEntry = @ptrCast(c.gtk_entry_new());
    c.gtk_entry_set_text(fld_timeout, "30");
    c.gtk_widget_set_size_request(@ptrCast(fld_timeout), w_field, -1);

    // Browse button
    const btn_browse = c.gtk_button_new_with_label("Browse…");
    c.gtk_widget_set_size_request(@ptrCast(btn_browse), w_field, -1);
    // _ = c.g_signal_connect_data(btn_browse, "clicked", @ptrCast(&on_browse_clicked), null, null, 0);

    // Save button
    const btn_save = c.gtk_button_new_with_label("Save");
    c.gtk_widget_set_size_request(@ptrCast(btn_save), w_field, -1);
    c.gtk_widget_set_halign(btn_save, c.GTK_ALIGN_END);
    // _ = c.g_signal_connect_data(btn_save, "clicked", @ptrCast(&on_save_clicked), null, null, 0);

    // Inner vbox
    const vbox = c.gtk_box_new(c.GTK_ORIENTATION_VERTICAL, 3);

    c.gtk_widget_set_margin_start(vbox, 6);
    c.gtk_widget_set_margin_end(vbox, 6);
    c.gtk_widget_set_margin_top(vbox, 6);
    c.gtk_widget_set_margin_bottom(vbox, 6);

    c.gtk_box_pack_start(@ptrCast(vbox), row("Push IP:", @ptrCast(fld_ip), null), 0, 0, 0);
    c.gtk_box_pack_start(@ptrCast(vbox), row("Push Frequency:", @ptrCast(fld_freq), c.gtk_label_new("seconds")), 0, 0, 0);
    c.gtk_box_pack_start(@ptrCast(vbox), row("Database File:", @ptrCast(fld_dbfile), btn_browse), 0, 0, 0);
    c.gtk_box_pack_start(@ptrCast(vbox), row("Timeout:", @ptrCast(fld_timeout), c.gtk_label_new("seconds")), 0, 0, 0);

    c.gtk_box_pack_end(@ptrCast(vbox), btn_save, 0, 0, 0);

    return vbox;
}

pub fn create_label() *c.GtkWidget {
    return c.gtk_label_new(label);
}
