# isolines-tesselation
Metal has no isoline tesselation feature unlike openGL so I was interested in implementing a basic demo using compute shaders. This demo demonstrates linear,
second and third degree bezier curve tesselations. Each tesselation mode can also be configured to have up to 2 extra control points to interpolate the
isoline "vertically".


Select the scene from the Scene tab in the top menu and choose the required tesselation mode. From the second menu, one can also choose 0,1 or 2 extra control points for interpolation along the vertical access. Control points are rendered green and can be dragged across the scene
