using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public readonly struct Vertex
{
    public readonly Vector3 XYZ;
    public readonly Vector2 UV;
    public readonly uint SmoothGroup;

    public Vertex(Vector3 xyz, Vector2 uv, uint smoothGroup = uint.MaxValue)
    {
        XYZ = xyz;
        UV = uv;
        SmoothGroup = smoothGroup;
    }

    public static Vertex operator +(Vertex a, Vertex b) =>
        new Vertex(a.XYZ + b.XYZ, a.UV + b.UV);

    public static Vertex operator -(Vertex a, Vertex b) =>
            new Vertex(a.XYZ + b.XYZ, a.UV + b.UV);

    public static Vertex operator *(Vertex a, float b) =>
        new Vertex(a.XYZ * b, a.UV * b);

    public static Vertex operator /(Vertex a, float b) =>
        new Vertex(a.XYZ / b, a.UV / b);

    public bool IsInRange(Vector3 target, float range)
    {
        return XYZ.DistanceSquaredTo(target) <= range;
    }
}

public readonly struct Tri
{
    private readonly Vertex _v1;
    private readonly Vertex _v2;
    private readonly Vertex _v3;

    public Tri(Vertex v1, Vertex v2, Vertex v3)
    {
        _v1 = v1;
        _v2 = v2;
        _v3 = v3;
    }

    public Vertex this[int index] => index switch
    {
        0 => _v1,
        1 => _v2,
        2 => _v3,
        _ => throw new IndexOutOfRangeException(
            "Tri vertices must be accessed with index 0-2")
    };

    public IEnumerable<Vertex> Vertices
    {
        get
        {
            yield return _v1;
            yield return _v2;
            yield return _v3;
        }
    }
}

public readonly struct Quad
{
    private readonly Vertex _v1;
    private readonly Vertex _v2;
    private readonly Vertex _v3;
    private readonly Vertex _v4;

    public Quad(Vertex v1, Vertex v2, Vertex v3, Vertex v4)
    {
        _v1 = v1;
        _v2 = v2;
        _v3 = v3;
        _v4 = v4;
    }

    public Vertex this[int index] => index switch
    {
        0 => _v1,
        1 => _v2,
        2 => _v3,
        3 => _v4,
        _ => throw new IndexOutOfRangeException(
            "Quad vertices must be accessed with index 0-3")
    };

    public IEnumerable<Vertex> Vertices
    {
        get
        {
            yield return _v1;
            yield return _v2;
            yield return _v3;
            yield return _v4;
        }
    }

    public readonly (Tri, Tri) Tris
    {
        get =>
            (new Tri(_v1, _v2, _v3),
            new Tri(_v3, _v4, _v1));
    }

    public Quad[] Subdivide()
    {
        Vertex[] newV = [
            (_v1 + _v2) / 2,
            (_v2 + _v3) / 2,
            (_v3 + _v4) / 2,
            (_v4 + _v1) / 2,
            (_v1 + _v2 + _v3 + _v4) / 4
        ];
        return [
            new Quad(_v1, newV[0], newV[4], newV[3]),
            new Quad(newV[0], _v2, newV[1], newV[4]),
            new Quad(_v3, newV[2], newV[4], newV[1]),
            new Quad(newV[2], _v4, newV[3], newV[4])
        ];
    }

    public int CornersInRange(Vector3 target, float range)
    {
        return Vertices.Count(x => x.IsInRange(target, range));
    }
}