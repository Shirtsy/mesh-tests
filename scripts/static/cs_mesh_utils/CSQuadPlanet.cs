using Godot;
using System;
using Num = System.Numerics;

public partial class CSQuadPlanet : MeshInstance3D
{   
    private Num.Vector3[][][] _a = [[[new Num.Vector3(0.0f, 0.0f, 0.0f)]]];
    private string _b = "textvar";

    public override void _Ready()
    {
        GD.Print("Hello from C# to Godot :)");
    }

    public override void _Process(double delta)
    {
    }
}