# raymenuz
## A dynamic menu library for raylib and raygui written in Zig
- - -
### Main Features:
- Hot reloading
- Semi-automatic element positioning
- Yaml defined menus
 - - -
### Usage
```zig
const RayMenu = @import("raymenuz").RayMenu;

pub const Player = struct {
    vel: Vector2,

    gravity: f32 = -100,
    jumpPower: f32 = 20,

    bounces: u16 = 0,
    xSpeed: i32 = 5,
};

pub const GameState = struct {
    player: *Player
};

pub fn main() !void {
    var state = GameState.init();
    var rayMenu = RayMenu(GameState).init(
        "src/menu.yml",
        &state,
        allocator
    );

    while (!rl.windowShouldClose()) { 
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);
        rl.beginMode2D(camera);
            // Draw your game
        rl.endMode2D();
        
        rayMenu.draw();
        if(rl.isKeyPressed(rl.KeyboardKey.r)) {
            if(rayMenu.reloadMenuItems()) |newDevMenu| {
                rayMenu = rayMenu;
            } else |err| {
                std.log.err("Failed to reload menu items {any}", .{err});
            }
        }
    }
}
```

```yaml
drawSettings:
  
  paddingY: 5
  
  startX: 25
  
  # width of elements
  width: 75
  
  # height of elements
  height: 10
itemDefs:
  -
    # 
    elementType: SLIDER
    
    # 
    statePath: player.gravity
    
    #
    displayValuePrefix: Gravity
    
    #
    menuItemType: float
    range:
      upper: 0
      lower: -400
  - elementType: VALUE_BOX
    statePath: player.xSpeed
    displayValuePrefix: X Speed
    menuItemType: int
    range:
      upper: 1000
      lower: 0
  - elementType: LABEL
    statePath: player.vel.y
    displayValuePrefix: Vel Y
    menuItemType: float
    range:
      upper: -1
      lower: -1
```

- - - 
### Menu Definition

#### drawSettings &rarr; DrawSettings defined in [raymenuutils.zig](src/raymenuutils.zig)
| Field    | Description                                                                                                        | Allowed Values |
|:---------|:-------------------------------------------------------------------------------------------------------------------|:---------------|
| paddingY | Vertical space between elements                                                                                    | Any integer    |
| startX   | Horizontal space between left side of screen and elements this does not account for text in the displayValuePrefix | Any integer    | 
| width    | Width of elements                                                                                                  | Any integer    | 
| height   | Height of elements                                                                                                 | Any integer    | 

#### itemDefs, list of YamlItemDef defined in [raymenuutils.zig](src/raymenuutils.zig)
| Field              | Description                                                                                               | Allowed Values                                     |
|:-------------------|:----------------------------------------------------------------------------------------------------------|:---------------------------------------------------|
| elementType        | Element type                                                                                              | SLIDER, VALUE_BOX, LABEL                           |
| statePath          | Path in provided state value                                                                              | Any string that maps to a value in the struct type | 
| displayValuePrefix | The label displayed to the left of the element                                                            | Any String                                         | 
| menuItemType       | Type of value at statePath, currently float(f16-32), int(i8-32), and string([]const u8) are only supporte | float, int, string                                 | 
| range              | Range for number based elements                                                                           | Valid struct definition                            | 

#### range, Range defined in [raymenuutils.zig](src/raymenuutils.zig)
While only used for number-based elements, it is still required for all elements for the sake of parsing and memory alignment.

| Field | Description | Allowed Values               |
|:------|:------------|:-----------------------------|
| lower | Lower bound | Any float less than upper    |
| upper | Upper bound | Any float greater than upper |

### raygui elements

| Element          | Status              | Supported Types |
|:-----------------|:--------------------|:----------------|
| **Slider**       | Supported           | `float`         |
| **ValueBox**     | Supported           | `int`           |
| **Label**        | Partially Supported | `int`, `float`  |
| **Button**       | Planned             | -               |
| **TextBox**      | Planned             | -               |
| **SliderBar**    | Planned             | -               |
| **ProgressBar**  | Planned             | -               |
| **StatusBar**    | Planned             | -               |
| **CheckBox**     | Planned             | -               |
| **LabelButton**  | Planned             | -               |
| **Toggle**       | Needs Consideration | -               |
| **ToggleGroup**  | Needs Consideration | -               |
| **ToggleSlider** | Needs Consideration | -               |
| **ComboBox**     | Needs Consideration | -               |
| **DropdownBox**  | Needs Consideration | -               |
| **Spinner**      | Needs Consideration | -               |
| **DummyRec**     | Needs Consideration | -               |
| **Grid**         | Needs Consideration | -               |
 - - -
### Known Errors
TODO
- - -
### Motivation
I wanted a developer menu, DearImgUi, microui, etc., for every raylib project I started, but I always found it difficult
to get them working when using languages other than C.

It occurred to me the raylib way of doing this was to use raygui. However, I never found using raygui enjoyable.
The cycle of pixel bumping and compiling felt cumbersome. I played around with auto placement for raygui elements
before, but it still required recompiling to add a label to watch a value I needed to see at that moment.

raymenuz is my solution to my problem. I hope that others find it useful.

- - - 
### Contributing
Please create an issue before putting up a pull request. I'm open to new features.
This is my first real Zig project, and I am open to suggestions on how
to improve the project structure, code structure, etc.

