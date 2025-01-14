#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(quads, equal_spacing, ccw) in;

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

// TODO: Declare tessellation evaluation shader inputs and outputs
layout(location = 0) patch in vec4 teseV1;
layout(location = 1) patch in vec4 teseV2;
layout(location = 2) patch in vec4 teseUp;
layout(location = 3) patch in vec4 teseBitangent;

layout(location = 0) out vec4 pos;
layout(location = 1) out vec3 normal;
layout(location = 2) out vec2 texCoords;

void main() {
    float u = gl_TessCoord.x; // [0, 0.5, 1] for quads
    float v = gl_TessCoord.y; // [0 ~ 1.0]

	// TODO: Use u and v to parameterize along the grass blade and output positions for each vertex of the grass blade
	mat4 vp = camera.proj * camera.view;

    vec3 v0 = gl_in[0].gl_Position.xyz;
	vec3 a = v0 + v * (teseV1.xyz - v0);
	vec3 b = teseV1.xyz + v * (teseV2.xyz - teseV1.xyz);
	vec3 c = a + v * (b - a);
	vec3 t1 = teseBitangent.xyz; 
	float w = teseV2.w;
	// curve points
	vec3 c0 = c - w * t1 * 0.5;
	vec3 c1 = c + w * t1 * 0.5;
	vec3 t0 = normalize(b-a);
	vec3 n = normalize(cross(t0,t1));
	float threshold = 0.35;
	// Figure 8: four shape
	//float t = u; // quad
	//float t = u + 0.5 * v - u * v;
	float t = u - u * v * v;
	//float t = 0.5 + (u - 0.5) * (1 - max(v - threshold, 0)/(1 - threshold));
 	vec3 p = (1 - t) * c0 + t * c1;
	gl_Position = vp * vec4(p, 1.0);
	pos = vec4(p, 1.0);
	normal = n;
	texCoords = vec2(u,v);
}
