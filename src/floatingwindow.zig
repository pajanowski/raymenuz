const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const WINDOW_STATUS_BAR_HEIGHT = 24;
const WINDOW_CLOSE_BUTTON_SIZE = 18;
const CLOSE_TITLE_SIZE_DELTA_HALF = (WINDOW_STATUS_BAR_HEIGHT - WINDOW_CLOSE_BUTTON_SIZE) / 2;
const MIN_WINDOW_SIZE = 100;

const DrawContentFn = *const fn(rl.Vector2, rl.Vector2) void;

pub const WindowOptions = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    minimized: bool = false,
    moving: bool = false,
    resizing: bool = false,
    drawContent: DrawContentFn,
    contentSize: rl.Vector2,
    scroll: rl.Vector2,
    title: []const u8,

    const Self = @This();

    // pub fn init(
    //     title: []const u8,
    //     size: rl.Vector2,
    //     position: rl.Vector2,
    //     drawContent: DrawContentFn,
    //     contentSize: rl.Vector2,
    //     scroll: rl.Vector2
    // ) Self {
    //     return Self{
    //         .minimized = false,
    //         .moving = false,
    //         .resizing = false,
    //         .title = title,
    //         .size = *size,
    //         .drawContent = drawContent,
    //         .position = *position,
    //         .scroll = *scroll,
    //         .contentSize = *contentSize
    //     };
    // }
};

pub fn floatingWindow(wo: *WindowOptions) void {
    var title_buf: [64]u8 = undefined;
    const title_text = std.fmt.bufPrintZ(&title_buf, "{s}", .{ wo.title }) catch "";
    const mouse_position = rl.getMousePosition();

    const is_left_pressed = rl.isMouseButtonPressed(rl.MouseButton.left);
    if(is_left_pressed and !(wo.moving) and !(wo.resizing)) {

        const title_collsion_rect = rl.Rectangle{.x = wo.position.x, .y = wo.position.y, .width = wo.size.x - WINDOW_CLOSE_BUTTON_SIZE - CLOSE_TITLE_SIZE_DELTA_HALF, .height = WINDOW_STATUS_BAR_HEIGHT};
        const resize_collision_rect = rl.Rectangle{.x = wo.position.x + wo.size.x - 20, .y = wo.position.y + wo.size.y - 20, .width = 20, .height = 20};

        if(rl.checkCollisionPointRec(mouse_position, title_collsion_rect)) {
            wo.moving = true;
        } else if(!(wo.minimized) and rl.checkCollisionPointRec(mouse_position, resize_collision_rect)) {
            wo.resizing = true;
        }
    }

    const screen_width = rl.getScreenWidth();
    const screen_width_f32 = @as(f32, @floatFromInt(screen_width));
    const screen_height = rl.getScreenHeight();
    const screen_height_f32 = @as(f32, @floatFromInt(screen_height));
    // window movement and resize update
    if(wo.moving) {
        const mouse_delta = rl.getMouseDelta();
        wo.position.x += mouse_delta.x;
        wo.position.y += mouse_delta.y;

        if(rl.isMouseButtonReleased(rl.MouseButton.left)) {
            wo.moving = false;

            if(wo.position.x < 0) {
                wo.position.x = 0;
            } else if(wo.position.x > screen_width_f32 - wo.size.x) {
                wo.position.x = screen_width_f32 - wo.size.x;
            }
            if(wo.position.y < 0) {
                wo.position.x = 0;
            } else if(wo.position.y > screen_height_f32) {
                wo.position.y = screen_height_f32 - WINDOW_STATUS_BAR_HEIGHT;
            }
        }
    } else if(wo.resizing) {
        if (mouse_position.x > wo.position.x) {
            wo.size.x = mouse_position.x - wo.position.x;
        }
        if (mouse_position.y > wo.position.y) {
            wo.size.y = mouse_position.y - wo.position.y;
        }
        // clamp window size to an arbitrary minimum value and the window size as the maximum
        if(wo.size.x < 100) {
            wo.size.x = 100;
        } else if(wo.size.x > screen_width_f32) {
            wo.size.x = screen_width_f32;
        }
        if(wo.size.y < 100) {
            wo.size.y = 100;
        } else if(wo.size.y > screen_height_f32) {
            wo.size.y = screen_height_f32;
        }

        if (rl.isMouseButtonReleased(rl.MouseButton.left)) {
            wo.resizing = false;
        }
    }
    // window and content drawing with scissor and scroll area
    if(wo.minimized) {
        _ = rg.statusBar(rl.Rectangle{ .x = wo.position.x, .y = wo.position.y, .width = wo.size.x, .height = WINDOW_STATUS_BAR_HEIGHT}, title_text);

        if (rg.button(rl.Rectangle{ .x = wo.position.x + wo.size.x - WINDOW_CLOSE_BUTTON_SIZE - CLOSE_TITLE_SIZE_DELTA_HALF,
            .y = wo.position.y + CLOSE_TITLE_SIZE_DELTA_HALF,
            .width = WINDOW_CLOSE_BUTTON_SIZE,
            .height = WINDOW_CLOSE_BUTTON_SIZE},
            "#120#")) {
            wo.minimized = false;
        }

    } else {
        wo.minimized = rg.windowBox(rl.Rectangle{ .x = wo.position.x, .y = wo.position.y, .width = wo.size.x, .height = wo.size.y}, title_text) > 0;

        // scissor and draw content within a scroll panel
        var scissor: rl.Rectangle = undefined;
        _ = rg.scrollPanel(rl.Rectangle{ .x = wo.position.x, .y = wo.position.y + WINDOW_STATUS_BAR_HEIGHT, .width = wo.size.x, .height = wo.size.y - WINDOW_STATUS_BAR_HEIGHT},
            null,
            rl.Rectangle{ .x = wo.position.x, .y = wo.position.y, .width = wo.contentSize.x, .height = wo.contentSize.y },
            &wo.scroll,
            &scissor);

        const require_scissor = wo.size.x < wo.contentSize.x or wo.size.y < wo.contentSize.y;

        if(require_scissor) {
            rl.beginScissorMode(@intFromFloat(scissor.x), @intFromFloat(scissor.y), @intFromFloat(scissor.width), @intFromFloat(scissor.height));
        }

        wo.drawContent(wo.position, wo.scroll);

        if(require_scissor) {
            rl.endScissorMode();
        }

        // draw the resize button/icon
        _ = rg.drawIcon(71, @intFromFloat(wo.position.x + wo.size.x - 20), @intFromFloat(wo.position.y + wo.size.y - 20), 1, rl.Color.gray);

    }
}

// for reference
pub fn drawContentExample(position: rl.Vector2, window_scroll: rl.Vector2) void {
    _ = rg.button(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 50 + window_scroll.y, .width = 100, .height = 25 }, "Button 1");
    _ = rg.button(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 100 + window_scroll.y, .width = 100, .height = 25 }, "Button 2");
    _ = rg.button(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 150  + window_scroll.y, .width = 100, .height = 25 }, "Button 3");
    _ = rg.label(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 200 + window_scroll.y, .width = 250, .height = 25 }, "A Label");
    _ = rg.label(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 250 + window_scroll.y, .width = 250, .height = 25 }, "Another Label");
    _ = rg.label(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 300 + window_scroll.y, .width = 250, .height = 25 }, "Yet Another Label");
}
