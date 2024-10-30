// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define round(a) floor(a + 0.5)
#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
#define texture flixel_texture2D

// third argument fix
vec4 flixel_texture2D(sampler2D bitmap, vec2 coord, float bias) {
	vec4 color = texture2D(bitmap, coord, bias);
	if (!hasTransform)
	{
		return color;
	}
	if (color.a == 0.0)
	{
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
	if (!hasColorTransform)
	{
		return color * openfl_Alphav;
	}
	color = vec4(color.rgb / color.a, color.a);
	mat4 colorMultiplier = mat4(0);
	colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
	colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
	colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
	colorMultiplier[3][3] = openfl_ColorMultiplierv.w;
	color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);
	if (color.a > 0.0)
	{
		return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
	}
	return vec4(0.0, 0.0, 0.0, 0.0);
}

// variables which is empty, they need just to avoid crashing shader
uniform float iTimeDelta;
uniform float iFrameRate;
uniform int iFrame;
#define iChannelTime float[4](iTime, 0., 0., 0.)
#define iChannelResolution vec3[4](iResolution, vec3(0.), vec3(0.), vec3(0.))
uniform vec4 iMouse;
uniform vec4 iDate;

// defining Blending functions
#define Blend(base, blend, funcf) 		vec4(funcf(base.r, blend.r), funcf(base.g, blend.g), funcf(base.b, blend.b), funcf(base.a, blend.a))
#define BlendAddthird(base, blend) 		min(base + (blend*0.3), vec4(1.0))
#define BlendAddtenth(base, blend) 		min(base + (blend*0.06), vec4(1.0))


// distance calculation between two points on the Y-plane
float dist(vec2 p0, vec2 pf){
     return sqrt((pf.y-p0.y)*(pf.y-p0.y));
}

////////////////////////////////////////////////////////////////////////////////////////////////////


// FRAGMENT SHADER

void mainImage( out vec4 color, in vec2 fragCoord )
{

// solid color for the background  
    vec4 sandcolor = vec4(0.9606, 0.6601, 0.1445, 1.0);
  
// textured noise, greyscale at a low resolution 64x64 pixels
    vec4 sandtexture = texture(iChannel1, fragCoord  / iResolution.xy);

// specular noise, colored at a higher resolution 256x256 pixels
    vec4 sandspecular = texture(iChannel0, fragCoord  / iResolution.xy);
    
// make extra specular maps and push their UVs around, to create a jittered fade between chunks of overlapping RGB colors.
    vec2 plusuv = floor(fragCoord-sin(iMouse.yy*0.03));
	vec2 reverseuv = floor(fragCoord+cos(iMouse.yy*0.018));
    vec4 sandspecular2 = texture(iChannel0, reverseuv  / iResolution.xy);
    vec4 sandspecular3 = texture(iChannel0, plusuv  / iResolution.xy);

// bump highlights on sand specular where RBG values meet, and cut out the rest
	sandspecular.xyz = sandspecular.xxx*sandspecular3.yyy*sandspecular2.zzz*vec3(2,2,2);

// calculate the distance between: the current pixel location, and the mouse position
    float d = abs(fragCoord.y - ((1.3 + sin(iTime))*200.0)); //for mouse input: abs(fragCoord.y - iMouse.y)
        
// reduce the scale to a fraction
    d = d*0.003;
    
// control the falloff of the gradient with a power/exponent
    d = pow(d,0.6);
  
// clamp the values of 'd', so that we cannot go above a 1.0 value
    d = min(d,1.0);
     
// blend together the sand color with a low opacity on the sand texture
    vec4 sandbase = BlendAddtenth(sandcolor,sandtexture);
    
// let's prep the glistening specular FX, by having it follow the diffuse sand texture
  	vec4 darkensand = mix(sandtexture,vec4(0,0,0,0), d);
    
// have the specular map be reduced by the diffuse texture (ingame: replace mouse cursor with player camera)
    vec4 gradientgen = mix(sandspecular, darkensand, d);
    
// blend the diffuse texture and the mouse-controlled hypothetical-specular gradient together   
    vec4 finalmix = BlendAddthird(sandbase, gradientgen);
  
// final output     
    color = finalmix;

}

////////////////////////////////////////////////////////////////////////////////////////////////////

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}