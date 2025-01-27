using Godot;
using System.Numerics;

public partial class CSQuadPlanet : MeshInstance3D
{
    private Vector3 _a = 2;
    private string _b = "textvar";

    public override void _Ready()
    {
        // Called every time the node is added to the scene.
        // Initialization here.
        GD.Print("Hello from C# to Godot :)");
    }

    public override void _Process(double delta)
    {
        // Called every frame. Delta is time since the last frame.
        // Update game logic here.
    }
}