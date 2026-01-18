const std = @import("std");
const mu = @import("menu_utils.zig");
const du = @import("draw_utils.zig");
const rl = @import("raylib");
const rg = @import("raygui");

const MenuItem = du.MenuItem;

pub const Slider = du.Slider;
pub const ValueBox = du.ValueBox;
pub const Label = du.Label;

pub const RayMenuWindowBuilder = struct {
    const MenuItemListType = std.array_list.Managed(*MenuItem);

    allocator: std.mem.Allocator,
    window: du.Window,
    menuItems: MenuItemListType,
    y: f32 = du.WINDOW_STATUS_BAR_HEIGHT + 4, // running y total
    maxWidth: f32 = 0, // running maxWidth
    drawSettings: mu.DrawSettings = mu.DrawSettings{
        .paddingY = 5,
        .startX = 5,
        .width = 75,
        .height = 10,
        .nameHeight = 10,
        .namePadding = 0
    },

    const Self = @This();

    pub fn init(title: []const u8, allocator: std.mem.Allocator) Self {
       return Self{
           .menuItems = MenuItemListType.init(allocator),
           .allocator = allocator,
           .window = du.Window{
               .title = title,
               .drawContent = RayMenu.drawContentCallback,
               .contentSize = undefined
           },
       };
    }

    pub fn addMenuItem(self: *Self, menuItem: MenuItem) !void {
        const drawSettings = self.drawSettings;
        var needsLabel = true;
        switch (menuItem) {
            .LABEL => needsLabel = false,
            else => {}
        }

        const ret = try self.allocator.create(MenuItem);
        ret.* = menuItem;

        switch (ret.*) {
            inline else => |*item| {

                if (needsLabel) {
                    item.props.nameBounds = rl.Rectangle{
                        .width = drawSettings.width,
                        .height = drawSettings.height,
                        .x = drawSettings.startX,
                        .y = self.y
                    };
                    self.y = self.y + drawSettings.nameHeight + drawSettings.namePadding;
                }

                item.props.name = try self.allocator.dupeZ(u8, item.props.name);
                item.props.itemBounds.height = drawSettings.height;
                item.props.itemBounds.width = drawSettings.width;
                item.props.itemBounds.x = drawSettings.startX;
                item.props.itemBounds.y = self.y;
                self.y = self.y + drawSettings.nameHeight + drawSettings.namePadding;
            },
        }

        const currentWidth = drawSettings.startX + drawSettings.width;
        if (currentWidth > self.maxWidth) self.maxWidth = currentWidth;
        self.y = self.y + drawSettings.height + drawSettings.paddingY;
        try self.menuItems.append(ret);
    }

    pub fn addMenuItems(self: *Self, menuItems: []const *MenuItem) !void {
        for (menuItems) |item| {
            try self.addMenuItem(item.*);
        }
    }

    pub fn build(self: *Self) !du.Window {
        const contentSize = rl.Vector2{ .x = (self.maxWidth + self.drawSettings.startX) * 2, .y = self.y - self.drawSettings.paddingY };
        const size = rl.Vector2{ .x = contentSize.x + 16, .y = contentSize.y + du.WINDOW_STATUS_BAR_HEIGHT + 8};

        self.window.contentSize = contentSize;
        self.window.size = size;
        self.window.position = rl.Vector2{.x = 2, .y = 2};
        self.window.scroll = rl.Vector2{.x = 0, .y = 0};
        self.window.menuItems = try self.menuItems.toOwnedSlice();
        return self.window;
    }
};

pub const RayMenu = struct {

    allocator: std.mem.Allocator,
    windows: std.array_list.Managed(*du.Window),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self {
            .allocator = allocator,
            .windows = std.array_list.Managed(*du.Window).init(allocator)
        };
    }

    pub fn addWindow(self: *Self, window: *du.Window) !void {
       try self.windows.append(window);
    }

    pub fn draw(self: *Self) void {
        for (self.windows.items) |window| {
            du.floatingWindow(window);
        }
    }

    fn drawContentCallback(window: *du.Window) void {
        const position = window.position;
        const scroll = window.scroll;

        for (window.menuItems) |menuItem| {
            switch(menuItem.*) {
                .SLIDER => |active| {
                    _ = rg.label(du.offsetRect(active.props.nameBounds, position, scroll), active.props.name);
                    var buf: [64:0]u8 = undefined;
                    const valueText = du.formatNumberLabel(&buf, active.valuePtr.*);
                    _ = rg.slider(du.offsetRect(active.props.itemBounds, position, scroll), "", valueText, active.valuePtr, active.range.lower, active.range.upper);
                },
                .VALUE_BOX => |_| {
                    std.debug.print("draw value\n", .{});
                },
                .LABEL => |_| {
                    std.debug.print("draw label\n", .{});
                }
            }
        }
    }
};