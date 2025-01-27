using System;
using Num = System.Numerics;

public readonly struct Vertex
{
    public readonly Num.Vector3 XYZ;
    public readonly Num.Vector2 UV;
    public readonly Num.Vector3 Normal;
    public readonly int SmoothGroup = -1;

    public Vertex() {}
}

public readonly struct Quad
{
    private readonly Vertex[] _verts;
    public readonly Vertex[] Verts
    {
        get => _verts;
        init
        {
            if (value.Length != 4)
            {
                throw new ArgumentOutOfRangeException
                (
                    "Parameter index is out of range.", nameof(value)
                );
            }
            else
            {
                _verts = value;
            }
        }
    }
    
    public readonly (Vertex[], Vertex[]) Tris
    {
        get =>
            ([Verts[0], Verts[1], Verts[2]],
            [Verts[2], Verts[3], Verts[0]]);
    }
}