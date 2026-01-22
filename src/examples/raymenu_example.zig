const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const raymenuz = @import("raymenuz");
const rm = raymenuz.raymenu;
const rmf = raymenuz.raymenu_from_file;

const Player = struct {
    rec: rl.Rectangle,
    speed: rl.Vector2,
    const Self = @This();

    pub fn init(
        startingPos: rl.Vector2
    ) Self {
        return Self{
            .rec = rl.Rectangle{
                .height = 10,
                .width = 10,
                .x = startingPos.x,
                .y = startingPos.y
            },
            .speed = rl.Vector2{
                .x = 2,
                .y = 2
            }
        };
    }
};

const State = struct {
   player: *Player
};

fn buttonTest() void {
    std.debug.print("Button works!!\n", .{});
}

fn buttonTest2() void {
    std.debug.print("Button 2 works!!\n", .{});
}

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    const screen_width = 800;
    const screen_height = 450;

    rl.initWindow(screen_width, screen_height, "raylib [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second

    var player = Player.init(
        rl.Vector2{.x = screen_width / 2, .y = screen_height / 2}
    );
    var state = State{.player = &player};
    const allocator = std.heap.page_allocator;

    const line = rm.Line.init("Separator line");
    const slider = rm.Slider.init("player x speed", raymenuz.mu.Range{.lower = 10, .upper = 20}, &state.player.speed.x);
    const slider2 = rm.Slider.init("player y speed", raymenuz.mu.Range{.lower = 10, .upper = 20}, &state.player.speed.y);

    var windowBuilder = rm.RayMenuWindowBuilder
        .init("This is a test window", allocator);
    try windowBuilder.startGroup("Actors Group");
        try windowBuilder.startGroup("Player Group");
            try windowBuilder.addMenuItem(slider);
            try windowBuilder.addMenuItem(line);
            try windowBuilder.addMenuItem(slider2);
        try windowBuilder.endGroup();
        const testButton = rm.Button.init("Test Button", buttonTest);
        try windowBuilder.addMenuItem(testButton);
    try windowBuilder.endGroup();

    try windowBuilder.startGroup("Group 2");
        const testButton2 = rm.Button.init("Test Button 2", buttonTest2);
        try windowBuilder.addMenuItem(testButton2);
    try windowBuilder.endGroup();

    var window = try windowBuilder.build();

    var rayMenu = rm.RayMenu
        .init(allocator);
    _ = try rayMenu.addWindow(&window);

    while (!rl.windowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            player.rec.x -= player.speed.x;
        }
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            player.rec.x += player.speed.x;
        }
        if (rl.isKeyDown(rl.KeyboardKey.up)) {
            player.rec.y -= player.speed.y;
        }
        if (rl.isKeyDown(rl.KeyboardKey.down)) {
            player.rec.y += player.speed.y;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.drawRectanglePro(player.rec, rl.Vector2{.x = player.rec.width / 2, .y = player.rec.height / 2}, 0, rl.Color.red);
        rl.clearBackground(rl.Color.ray_white);
        rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);
        //----------------------------------------------------------------------------------

        rayMenu.draw();
    }
}