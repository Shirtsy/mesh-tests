using System.Collections.Generic;
using Godot;
using GCollection = Godot.Collections;
using System.Linq;

public partial class PlanetUtils : GodotObject
{   
    public static GCollection.Dictionary<string, Variant> GeneratePlanetMeshes(
        double radius,
        Vector3 markerPos,
        double[] lodDist,
        Noise planetNoise)
    {
        (Vertex[] Draw, Vertex[] Collider) verts = GeneratePlanetVerts(
            radius, markerPos, lodDist, planetNoise);
        return new GCollection.Dictionary<string, Variant>()
        {
            {"draw", VertsToMesh(verts.Draw)},
            {"collider", VertsToMesh(verts.Collider).CreateTrimeshShape()}
        };  
    }

    private static Mesh VertsToMesh(Vertex[] vertsArr)
        {
            SurfaceTool st = new SurfaceTool();
            st.Begin(Mesh.PrimitiveType.Triangles);
            foreach (Vertex vert in vertsArr)
            {
                st.SetSmoothGroup(vert.SmoothGroup);
                st.SetUV(vert.UV);
                st.AddVertex(vert.XYZ);
            }
            st.Index();
            st.GenerateNormals();
            return st.Commit();
        }

    private static (Vertex[] Draw, Vertex[] Collider) GeneratePlanetVerts(
        double radius,
        Vector3 markerPos,
        double[] lodDist,
        Noise planetNoise)
    {
        List<Quad> processQuads = CreateUnitCube();
        List<Quad> newProcessQuads = new List<Quad>();
        List<Quad> drawQuads = new List<Quad>();
        List<Quad> colliderQuads = new List<Quad>();
        foreach (double distance in lodDist)
        {
            if (processQuads.Count == 0) { break; }
            newProcessQuads.Clear();
            colliderQuads.Clear();
            foreach (Quad quad in processQuads)
            {
                if (quad.CornersInRange(markerPos, (float)distance) > 0)
                {
                    newProcessQuads.AddRange(quad.Subdivide()
                        .Select(x => x.Normalized().Scale((float)radius)));
                }
                else
                {
                    drawQuads.Add(quad.Normalized().Scale((float)radius));
                    // colliderQuads.Add(quad.Normalized() * (float)radius);
                }
            }
            processQuads = new List<Quad>(newProcessQuads);
        }
        drawQuads.AddRange(processQuads);
        colliderQuads = processQuads;
        // GD.Print($"Length: {newProcessQuads.Count}");

        Vertex[] QuadsToVerts(IEnumerable<Quad> quads)
        {
            return quads
                .SelectMany(quad => new Tri[2] { quad.Tris.Item1, quad.Tris.Item2 })
                .SelectMany(tri => tri.Vertices)
                .ToArray();
        }
        return (QuadsToVerts(drawQuads),
            QuadsToVerts(colliderQuads));
    }

    public static List<Quad> CreateUnitCube()
    {
        var quads = new List<Quad>();

        // Define the 8 vertices of a unit cube centered at (0,0,0)
        Vertex v000 = new Vertex(new Vector3(-1, -1, -1), new Vector2(0, 0));
        Vertex v100 = new Vertex(new Vector3(1, -1, -1), new Vector2(1, 0));
        Vertex v110 = new Vertex(new Vector3(1, 1, -1), new Vector2(1, 1));
        Vertex v010 = new Vertex(new Vector3(-1, 1, -1), new Vector2(0, 1));
        Vertex v001 = new Vertex(new Vector3(-1, -1, 1), new Vector2(0, 0));
        Vertex v101 = new Vertex(new Vector3(1, -1, 1), new Vector2(1, 0));
        Vertex v111 = new Vertex(new Vector3(1, 1, 1), new Vector2(1, 1));
        Vertex v011 = new Vertex(new Vector3(-1, 1, 1), new Vector2(0, 1));

        // Create 6 quads for each face of the cube (in clockwise winding order)
        quads.Add(new Quad(v000, v100, v110, v010)); // Front face
        quads.Add(new Quad(v100, v101, v111, v110)); // Right face
        quads.Add(new Quad(v101, v001, v011, v111)); // Back face
        quads.Add(new Quad(v001, v000, v010, v011)); // Left face
        quads.Add(new Quad(v010, v110, v111, v011)); // Top face
        quads.Add(new Quad(v001, v101, v100, v000)); // Bottom face

        return quads;
    }
}