using Godot;

public static class PlanetUtils : object
{   
    public static (Mesh Draw, Mesh Collider) GenerateMesh(
        double radius,
        Vector3 markerPos,
        double[] lodDist,
        Noise planetNoise,
        double noiseMult)
    {
        Mesh ProcessVertArray(Vertex[] vertsArr)
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
        (Vertex[] Draw, Vertex[] Collider) verts = GenerateVerts(
            radius, markerPos, lodDist, planetNoise, noiseMult);
        return (ProcessVertArray(verts.Draw), ProcessVertArray(verts.Collider));
    }

    private static (Vertex[] Draw, Vertex[] Collider) GenerateVerts(
        double radius,
        Vector3 markerPos,
        double[] lodDist,
        Noise planetNoise,
        double noiseMult)
    {
        return ([new Vertex()], [new Vertex()]);
    }
}