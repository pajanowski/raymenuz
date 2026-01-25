const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const raymenuz = @import("raymenuz");
const rm = raymenuz.raymenu;
const rmf = raymenuz.raymenu_from_file;

const Player = struct {
    rec: rl.Rectangle,
    speed: rl.Vector2,
    health: f32,
    score: i32,
    level: i32,
    enabled: bool,
    godMode: bool,
    difficulty: i32,
    weapon: i32,
    dropdownEdit: bool,
    textboxEdit: bool,
    spinnerEdit: bool,
    scoreDisplay: i32,
    musicToggle: i32,
    nameBuffer: [64:0]u8,
    mouseCell: rl.Vector2,
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
                .x = 10,
                .y = 10
            },
            .health = 100.0,
            .score = 0,
            .level = 1,
            .enabled = true,
            .godMode = false,
            .difficulty = 1,
            .weapon = 0,
            .dropdownEdit = false,
            .textboxEdit = true,
            .spinnerEdit = true,
            .scoreDisplay = 0,
            .musicToggle = 0,
            .nameBuffer = std.mem.zeroes([64:0]u8),
            .mouseCell = rl.Vector2{.x = 0, .y = 0}
        };
    }
};

const State = struct {
   player: *Player
};

fn resetPlayer(player: *Player) void {
    player.speed.x = 10;
    player.speed.y = 10;
    player.health = 100.0;
    player.score = 0;
    std.debug.print("Player reset!\n", .{});
}

fn buttonTest() void {
    std.debug.print("Button works!!\n", .{});
}

fn buttonTest2() void {
    std.debug.print("Label Button clicked!!\n", .{});
}

pub fn main() !void {
    const screen_width = 800;
    const screen_height = 600;

    rl.initWindow(screen_width, screen_height, "raymenuz - All raygui Elements Example");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var player = Player.init(
        rl.Vector2{.x = screen_width / 2, .y = screen_height / 2}
    );
    _ = std.fmt.bufPrintZ(&player.nameBuffer, "Player1", .{}) catch "";

    const allocator = std.heap.page_allocator;

    const drawSettings = rm.DrawSettings{
        .paddingY = 3,
        .startX = 5,
        .width = 140,
        .height = 15,
        .nameHeight = 12,
        .namePadding = 2
    };

    var windowBuilder = rm.RayMenuWindowBuilder.init("raygui Elements Demo", drawSettings, allocator);
    var windowBuilder2 = rm.RayMenuWindowBuilder.init("Window 2", drawSettings, allocator);
    var windowBuilder3 = rm.RayMenuWindowBuilder.init("Window 3", drawSettings, allocator);

    // Basic Controls Group
    try windowBuilder.startGroup("Basic Controls");
        // Button
        const testButton = rm.Button.init("Click Me!", buttonTest);
        try windowBuilder.addMenuItem(testButton);

        // LabelButton
        const labelButton = rm.LabelButton.init("Label Button", buttonTest2);
        try windowBuilder.addMenuItem(labelButton);

        const line1 = rm.Line.init("This is a line");
        try windowBuilder.addMenuItem(line1);

        // Toggle
        const toggle = rm.Toggle.init("Enable Player", &player.enabled);
        try windowBuilder.addMenuItem(toggle);

        // CheckBox
        const checkbox = rm.CheckBox.init("God Mode", &player.godMode);
        try windowBuilder.addMenuItem(checkbox);
    try windowBuilder.endGroup();

    // Sliders & Progress Group
    try windowBuilder2.startGroup("Sliders & Progress");
        // Slider
        const speedSlider = rm.Slider.init("Speed X", raymenuz.mu.Range{.lower = 0, .upper = 50}, &player.speed.x);
        try windowBuilder2.addMenuItem(speedSlider);

        const speedSlider2 = rm.Slider.init("Speed Y", raymenuz.mu.Range{.lower = 0, .upper = 50}, &player.speed.y);
        try windowBuilder2.addMenuItem(speedSlider2);

        // SliderBar
        const healthSlider = rm.SliderBar.init("Health", raymenuz.mu.Range{.lower = 0, .upper = 100}, &player.health);
        try windowBuilder2.addMenuItem(healthSlider);

        // ProgressBar
        const healthProgress = rm.ProgressBar.init("HP Bar", raymenuz.mu.Range{.lower = 0, .upper = 100}, &player.health);
        try windowBuilder2.addMenuItem(healthProgress);
    try windowBuilder2.endGroup();

    // Value Inputs Group
    try windowBuilder3.startGroup("Value Inputs");
        // ValueBox (editable integer)
        const scoreValue = rm.ValueBox.init("Score", raymenuz.mu.Range{.lower = 0, .upper = 9999}, &player.score);
        try windowBuilder3.addMenuItem(scoreValue);

        // Spinner
        const levelSpinner = rm.Spinner.init("Level", raymenuz.mu.Range{.lower = 1, .upper = 99}, &player.level, &player.spinnerEdit);
        try windowBuilder3.addMenuItem(levelSpinner);

        // TextBox
        const nameInput = rm.TextBox.init("Name", &player.nameBuffer, 64, &player.textboxEdit);
        try windowBuilder3.addMenuItem(nameInput);

        // Label (read-only display)
        const weaponLabel = rm.Label.init("Current Weapon ID", &player.weapon);
        try windowBuilder3.addMenuItem(weaponLabel);
    try windowBuilder3.endGroup();

    // Selection Controls Group
    try windowBuilder2.startGroup("Selection Controls");
        // ComboBox
        const difficultyCombo = rm.ComboBox.init("Difficulty", "Easy;Normal;Hard;Insane", &player.difficulty);
        try windowBuilder2.addMenuItem(difficultyCombo);

        // DropdownBox
        const weaponDropdown = rm.DropdownBox.init("Weapon", "Sword;Bow;Staff;Axe", &player.weapon, &player.dropdownEdit);
        try windowBuilder2.addMenuItem(weaponDropdown);

        // ToggleGroup
        const scoreToggle = rm.ToggleGroup.init("Score Display", "Off;Small;Large", &player.scoreDisplay);
        try windowBuilder2.addMenuItem(scoreToggle);

        // ToggleSlider
        const toggleSlider = rm.ToggleSlider.init("Music", "ON;OFF", &player.musicToggle);
        try windowBuilder2.addMenuItem(toggleSlider);
    try windowBuilder2.endGroup();

    // Utility Elements Group
    try windowBuilder2.startGroup("Utility Elements");
        // StatusBar
        const status = rm.StatusBar.init("Status: Ready");
        try windowBuilder2.addMenuItem(status);

        // DummyRec
        const dummy = rm.DummyRec.init("Dummy Rectangle");
        try windowBuilder2.addMenuItem(dummy);

        // Grid
        const grid = rm.Grid.init("Grid", 10, 3, &player.mouseCell);
        try windowBuilder2.addMenuItem(grid);
    try windowBuilder2.endGroup();

    var window = try windowBuilder.build();
    var window2 = try windowBuilder2.build();
    var window3 = try windowBuilder3.build();
    var rayMenu = rm.RayMenu.init(allocator);
    try rayMenu.addWindow(&window);
    try rayMenu.addWindow(&window2);
    try rayMenu.addWindow(&window3);
    rayMenu.build();

    while (!rl.windowShouldClose())
    {
        // Update
        if (player.enabled) {
            if (rl.isKeyDown(rl.KeyboardKey.left)) {
                player.rec.x -= player.speed.x / 10.0;
            }
            if (rl.isKeyDown(rl.KeyboardKey.right)) {
                player.rec.x += player.speed.x / 10.0;
            }
            if (rl.isKeyDown(rl.KeyboardKey.up)) {
                player.rec.y -= player.speed.y / 10.0;
            }
            if (rl.isKeyDown(rl.KeyboardKey.down)) {
                player.rec.y += player.speed.y / 10.0;
            }
        }

        // Keep player on screen
        if (player.rec.x < 0) player.rec.x = 0;
        if (player.rec.x > screen_width - player.rec.width) player.rec.x = screen_width - player.rec.width;
        if (player.rec.y < 0) player.rec.y = 0;
        if (player.rec.y > screen_height - player.rec.height) player.rec.y = screen_height - player.rec.height;

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.dark_gray);

        // Draw player
        const playerColor = if (player.godMode) rl.Color.gold else rl.Color.red;
        rl.drawRectanglePro(player.rec, rl.Vector2{.x = player.rec.width / 2, .y = player.rec.height / 2}, 0, playerColor);

        // Draw info text
        var infoBuf: [128:0]u8 = undefined;
        const infoText = std.fmt.bufPrintZ(&infoBuf, "Use Arrow Keys to Move | Level: {d} | Health: {d:.1}", .{player.level, player.health}) catch "Info";
        rl.drawText(infoText, 10, screen_height - 30, 16, rl.Color.white);

        const titleText = "raymenuz - All raygui Elements Example";
        rl.drawText(titleText, 10, 10, 20, rl.Color.white);

        // Draw menu
        rayMenu.draw();
    }
}