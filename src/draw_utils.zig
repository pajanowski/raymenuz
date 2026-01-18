const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const mu = @import("menu_utils.zig");

pub const MenuItem = union(mu.UiElementType) {
    SLIDER: Slider,
    VALUE_BOX: ValueBox,
    LABEL: Label
};

pub const CommonItemProps = struct {
    itemBounds: rl.Rectangle = undefined,
    nameBounds: rl.Rectangle = undefined,
    name: [:0]const u8,
};

pub const Slider = struct {
    props: CommonItemProps,
    range: mu.Range,
    valuePtr: *f32,

    const Self = @This();

    pub fn init(
        name: [:0]const u8,
        range: mu.Range,
        valuePtr: *f32
    ) MenuItem {
        return MenuItem{
            .SLIDER = Slider{
                .props = CommonItemProps{
                    .name = name
                },
                .range = range,
                .valuePtr = valuePtr
            }
        };
    }
};

pub const ValueBox = struct {
    props: CommonItemProps,
    range: mu.Range,
    valuePtr: *i32
};

pub const Label = struct {
    props: CommonItemProps,
    range: mu.Range,
    valuePtr: *i32
};
pub fn drawFloatElements(menuItem: *mu.MenuItem, valuePtr: anytype, position: rl.Vector2, scroll: rl.Vector2, disable: bool) void {
    const menuProperties = menuItem.getMenuProperties();
    switch(menuProperties.elementType.?) {
        .SLIDER => {
            const range = menuItem.getRange();
            drawSlideBar(menuProperties, range, valuePtr, position, scroll, disable);
        },
        .LABEL => {
            drawNumberLabel(menuProperties, valuePtr, position, scroll);
        },
        else => {}
    }
}

pub fn drawIntElements(menuItem: *mu.MenuItem, valuePtr: *i32, position: rl.Vector2, scroll: rl.Vector2) void {
    const menuProperties = menuItem.getMenuProperties();
    if (menuProperties.elementType) |elementType| {
        switch(elementType) {
            .VALUE_BOX => {
                const range = menuItem.getRange();
                drawValueBox(menuProperties, range, valuePtr, position, scroll);
            },
            .LABEL => {
                drawNumberLabel(menuProperties, valuePtr, position, scroll);
            },
            else => {}
        }
    }
}

pub fn drawStringElements(menuItem: *mu.MenuItem, valuePtr: *[]const u8, position: rl.Vector2, scroll: rl.Vector2) void {
    const menuProperties = menuItem.getMenuProperties();
    if (menuProperties.elementType) |elementType| {
        switch(elementType) {
            .LABEL => {
                drawStringLabel(menuProperties, valuePtr, position, scroll);
            },
            else => {}
        }
    }
}

pub fn formatNumberLabel(buf: []u8, value: anytype) [:0]const u8 {
    return std.fmt.bufPrintZ(buf, "{d:.5}", .{ value }) catch "0";
}

pub fn offsetRect(rect: rl.Rectangle, position: rl.Vector2, scroll: rl.Vector2) rl.Rectangle {
    return rl.Rectangle {
        .x = rect.x + position.x + scroll.x,
        .y = rect.y + position.y + scroll.y,
        .width = rect.width,
        .height = rect.height
    };
}

pub fn drawSlideBar(menuProperties: mu.MenuProperties, range: mu.Range, valuePtr: anytype, position: rl.Vector2, scroll: rl.Vector2, disable: bool) void {
    const predrawValue: f32 = valuePtr.*;
    var textLabelBuf: [64]u8 = undefined;
    const text = formatNumberLabel(&textLabelBuf, valuePtr.*);
    var nameLabelBuf: [64]u8 = undefined;
    const name = std.fmt.bufPrintZ(&nameLabelBuf, "{s}", .{ menuProperties.name }) catch "";
    _ = rg.label(offsetRect(menuProperties.nameBounds, position, scroll), name);
    _ = rg.sliderBar(offsetRect(menuProperties.bounds, position, scroll), "", text, valuePtr, range.lower, range.upper);
    if (disable) {
        valuePtr.* = predrawValue;
    }
}

pub fn drawValueBox(menuProperties: mu.MenuProperties, range: mu.Range, valuePtr: *i32, position: rl.Vector2, scroll: rl.Vector2) void {
    var label_buf: [64]u8 = undefined;
    const name = std.fmt.bufPrintZ(&label_buf, "{s}", .{ menuProperties.name }) catch "";
    _ = rg.label(offsetRect(menuProperties.nameBounds, position, scroll), name);
    _ = rg.valueBox(offsetRect(menuProperties.bounds, position, scroll), "", valuePtr, @intFromFloat(range.lower), @intFromFloat(range.upper), true);
}

pub fn drawStringLabel(menuProperties: mu.MenuProperties, valuePtr: *[]const u8, position: rl.Vector2, scroll: rl.Vector2) void {
    var label_buf: [64]u8 = undefined;
    const prefix = menuProperties.name;
    const text = std.fmt.bufPrintZ(&label_buf, "{s} {s}", .{ prefix, valuePtr.* }) catch "";
    _ = rg.label(offsetRect(menuProperties.bounds, position, scroll), text);
}

pub fn drawNumberLabel(menuProperties: mu.MenuProperties, valuePtr: anytype, position: rl.Vector2, scroll: rl.Vector2) void {
    var label_buf: [64]u8 = undefined;
    const text = formatNumberLabel(&label_buf, valuePtr.*);
    _ = rg.label(offsetRect(menuProperties.bounds, position, scroll), text);
}


pub const WINDOW_STATUS_BAR_HEIGHT = 24;
const WINDOW_CLOSE_BUTTON_SIZE = 18;
const CLOSE_TITLE_SIZE_DELTA_HALF = (WINDOW_STATUS_BAR_HEIGHT - WINDOW_CLOSE_BUTTON_SIZE) / 2;
const MIN_WINDOW_SIZE = 100;

const DrawContentFn = *const fn(wo: *Window) void;

pub const Window = struct {
    title: []const u8,
    position: rl.Vector2 = undefined,
    size: rl.Vector2 = undefined,
    minimized: bool = false,
    moving: bool = false,
    resizing: bool = false,
    drawContent: DrawContentFn = undefined,
    contentSize: rl.Vector2 = undefined,
    scroll: rl.Vector2 = undefined,
    user_data: ?*anyopaque = null,
    menuItems: []*MenuItem = undefined,

    const Self = @This();
};

pub fn floatingWindow(wo: *Window) void {
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

        wo.drawContent(wo);

        if(require_scissor) {
            rl.endScissorMode();
        }

        // draw the resize button/icon
        _ = rg.drawIcon(71, @intFromFloat(wo.position.x + wo.size.x - 20), @intFromFloat(wo.position.y + wo.size.y - 20), 1, rl.Color.gray);

    }
}

fn drawContent(position: rl.Vector2, window_scroll: rl.Vector2) void {
    _ = rg.button(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 50 + window_scroll.y, .width = 100, .height = 25 }, "Button 1");
    _ = rg.button(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 100 + window_scroll.y, .width = 100, .height = 25 }, "Button 2");
    _ = rg.button(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 150  + window_scroll.y, .width = 100, .height = 25 }, "Button 3");
    _ = rg.label(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 200 + window_scroll.y, .width = 250, .height = 25 }, "A Label");
    _ = rg.label(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 250 + window_scroll.y, .width = 250, .height = 25 }, "Another Label");
    _ = rg.label(rl.Rectangle{ .x = position.x + 20 + window_scroll.x, .y = position.y + 300 + window_scroll.y, .width = 250, .height = 25 }, "Yet Another Label");
}