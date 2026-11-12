# blender -b -P blender_views.py -- <modelo.glb> <salida_prefijo>
# Importa el modelo, imprime cuántas caras tiene y lo renderiza desde 4 lados (para revisarlo sin abrir nada).
import bpy, sys, math
from mathutils import Vector

args = sys.argv[sys.argv.index("--") + 1:]
src, out = args[0], args[1]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)
meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
faces = sum(len(o.data.polygons) for o in meshes)
lo = Vector((1e9, 1e9, 1e9)); hi = Vector((-1e9, -1e9, -1e9))
for o in meshes:
    for c in o.bound_box:
        w = o.matrix_world @ Vector(c)
        lo = Vector(map(min, lo, w)); hi = Vector(map(max, hi, w))
size = hi - lo
center = (lo + hi) / 2
print("MESHES %d FACES %d SIZE %.3f %.3f %.3f" % (len(meshes), faces, size.x, size.y, size.z))
for o in meshes:
    for m in o.data.materials:
        if m and m.node_tree:
            print("MAT", m.name, [n.image.size[:] for n in m.node_tree.nodes if n.type == "TEX_IMAGE" and n.image])

scene = bpy.context.scene
scene.render.engine = "BLENDER_EEVEE_NEXT"
scene.render.resolution_x = 512
scene.render.resolution_y = 512
scene.render.film_transparent = False
world = bpy.data.worlds.new("w"); scene.world = world
world.use_nodes = True
world.node_tree.nodes["Background"].inputs[0].default_value = (0.85, 0.88, 0.92, 1)
world.node_tree.nodes["Background"].inputs[1].default_value = 1.0
sun = bpy.data.objects.new("sun", bpy.data.lights.new("sun", "SUN")); sun.data.energy = 3.0
sun.rotation_euler = (math.radians(50), 0, math.radians(30)); scene.collection.objects.link(sun)
cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam")); scene.collection.objects.link(cam)
scene.camera = cam
r = max(size) * 2.2
for i, ang in enumerate([0, 90, 180, 270]):
    a = math.radians(ang)
    cam.location = center + Vector((math.sin(a) * r, -math.cos(a) * r, r * 0.45))
    d = center - cam.location
    cam.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()
    scene.render.filepath = "%s_%d.png" % (out, i)
    bpy.ops.render.render(write_still=True)
