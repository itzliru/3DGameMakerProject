if (global.paused) {
    draw_set_color(c_white);
    draw_set_alpha(0.8);
    draw_text(display_get_width()/2 - 50, display_get_height()/2, "PAUSED");
    draw_set_alpha(1);
}
