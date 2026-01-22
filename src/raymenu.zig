const std = @import("std");
const mu = @import("menu_utils.zig");
const du = @import("draw_utils.zig");
const rl = @import("raylib");

const MenuItem = du.MenuItem;
pub const DrawSettings = mu.DrawSettings;

pub const Slider = du.Slider;
pub const ValueBox = du.ValueBox;
pub const Label = du.Label;
pub const Line = du.Line;
pub const Button = du.Button;

const GroupBox = du.GroupBox;

const X_INDENT = 5;
pub const RayMenuWindowBuilder = struct {
    const MenuItemListType = std.array_list.Managed(*MenuItem);

    allocator: std.mem.Allocator,
    window: du.Window,
    menuItems: MenuItemListType,
    z0Items: MenuItemListType,
    boundsCalc: du.BoundsCalculator,
    x: f32 = 0,
    maxWidth: f32 = 0, // running maxWidth
    drawSettings: mu.DrawSettings = mu.DrawSettings{
        .paddingY = 5,
        .startX = 5,
        .width = 75,
        .height = 10,
        .nameHeight = 10,
        .namePadding = 0
    },
    groupBoxStack: MenuItemListType,

    const Self = @This();

    pub fn init(title: []const u8,
        drawSettings: mu.DrawSettings,
        allocator: std.mem.Allocator) Self {
       return Self{
           .menuItems = MenuItemListType.init(allocator),
           .z0Items = MenuItemListType.init(allocator),
           .allocator = allocator,
           .window = du.Window{
               .title = title,
               .drawContent = RayMenu.drawContentCallback,
               .contentSize = undefined
           },
           .groupBoxStack = MenuItemListType.init(allocator),
           .boundsCalc = du.BoundsCalculator.init(drawSettings),
           .drawSettings = drawSettings
       };
    }
    
    pub fn startGroup(self: *Self, name: [:0]const u8) !void {
        const menuItem = try self.allocator.create(MenuItem);
        self.x = self.x + X_INDENT;
        self.boundsCalc.padY();
        const currentY = self.boundsCalc.getY();
        menuItem.* = @unionInit(MenuItem, @tagName(mu.UiElementType.GROUP_BOX), GroupBox{
            .props = du.CommonItemProps{
                .name = name,
                .itemBounds = rl.Rectangle{
                    .x = self.x,
                    .y = currentY,
                    .width = (self.drawSettings.startX + self.drawSettings.width + self.drawSettings.startX) * 2 - 2 * self.x,
                    .height = -1,
                }
            }
        });
        self.boundsCalc.padY();
        try self.groupBoxStack.append(menuItem);
    }

    pub fn endGroup(self: *Self) !void {
        const groupBox = self.groupBoxStack.pop();
        if (groupBox) |unwrapped| {
            const currentY = self.boundsCalc.getY();
            unwrapped.GROUP_BOX.props.itemBounds.height = currentY - unwrapped.GROUP_BOX.props.itemBounds.y;
            self.boundsCalc.padY();
            self.x = self.x - X_INDENT;
            try self.z0Items.append(unwrapped);
        } else {
            @panic("Attempted to end a group when never started");
        }
    }

    pub fn addMenuItem(self: *Self, menuItem: MenuItem) !void {
        var needsLabel = true;
        switch (menuItem) {
            .LABEL => needsLabel = false,
            .LINE => needsLabel = false,
            .BUTTON => needsLabel = false,
            else => {}
        }

        const ret = try self.allocator.create(MenuItem);
        ret.* = menuItem;

        switch (ret.*) {
            .BUTTON => |*item| {
                item.props.name = try self.allocator.dupeZ(u8, item.props.name);
                item.props.itemBounds = self.boundsCalc.getItemBoundsWithHeight(self.x, self.drawSettings.buttonHeight);
                self.boundsCalc.advanceYBy(self.drawSettings.buttonHeight);
                self.boundsCalc.padY();
            },
            inline else => |*item| {
                item.props.nameBounds = self.boundsCalc.getNameBounds(self.x, needsLabel);
                item.props.name = try self.allocator.dupeZ(u8, item.props.name);
                item.props.itemBounds = self.boundsCalc.getItemBounds(self.x);
                self.boundsCalc.advanceY();
            },
        }

        try self.menuItems.append(ret);
    }

    pub fn build(self: *Self) !du.Window {
        const contentSize = rl.Vector2{
            .x = (self.drawSettings.startX + self.drawSettings.width + self.drawSettings.startX) * 2,
            .y = self.boundsCalc.getY() - self.boundsCalc.lastAdvancedAmount
        };
        const size = rl.Vector2{ .x = contentSize.x + 16, .y = contentSize.y + du.WINDOW_STATUS_BAR_HEIGHT + 8};

        self.window.contentSize = contentSize;
        self.window.size = size;
        self.window.position = rl.Vector2{.x = 2, .y = 2};
        self.window.scroll = rl.Vector2{.x = 0, .y = 0};
        self.window.menuItems = try self.menuItems.toOwnedSlice();
        self.window.z0Items = try self.z0Items.toOwnedSlice();
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

        const n = window.z0Items.len;
        for(0..n) |reverse_i| {
            const i = n - 1 - reverse_i;
            const item = window.z0Items[i];
            switch(item.*) {
                .GROUP_BOX => |active| {
                    du.drawGroupBox(&active, position, scroll);
                },
                else => @panic("An unsupported menuItem type made it into z0items")
            }
        }

        for (window.menuItems) |menuItem| {
            switch(menuItem.*) {
                .SLIDER => |active| {
                    du.drawSlider(&active, position, scroll);
                },
                .VALUE_BOX => |_| {
                    std.debug.print("draw value\n", .{});
                },
                .LABEL => |_| {
                    std.debug.print("draw label\n", .{});
                },
                .LINE => |active| {
                    du.drawLine(&active, position, scroll);
                },
                .BUTTON => |active| {
                    du.drawButton(&active, position, scroll);
                },
                else => unreachable
            }
        }
    }
};