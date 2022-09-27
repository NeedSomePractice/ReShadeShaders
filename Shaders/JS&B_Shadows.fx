
//JS&B Shadows by NeedSomePractice

//Settings

#include "ReShadeUI.fxh"

#include "ReShade.fxh"

uniform float transparency < __UNIFORM_DRAG_FLOAT1
	ui_min = 0.1; ui_max = 1.0; ui_step = 0.1;
	ui_tooltip = "Shadow Transparency";
	ui_label = "Transparency";
> = 0.5;

uniform float direction < __UNIFORM_DRAG_FLOAT1
	ui_min = 0.0; ui_max = 345.0; ui_step = 15.0;
	ui_tooltip = "Shadow Direction";
	ui_label = "Direction";
> = 225.0;

uniform float distance < __UNIFORM_DRAG_FLOAT1
	ui_min = 0.0; ui_max = 100.0; ui_step = 5.0;
	ui_tooltip = "Shadow Distance";
	ui_label = "Distance";
> = 15.0;

float3 Shadows1(in float4 pos : SV_Position, in float2 texcoord : TEXCOORD) : COLOR
{
	float dir = direction / 180.0 * 3.14159;
	float2 shift = float2(cos(dir) * distance / 1920.0, sin(dir) * distance / 1080.0);
	float3 shadow_c = float3(0.0, 0.0, 0.0);
	float shadow_v = 0.0;
	float2 coords = texcoord + shift;
	
	if (coords.x >= 0.0 && coords.x <= 1.0 && coords.y >= 0.0 && coords.y <= 1.0)
	{
		shadow_c = tex2D(ReShade::BackBuffer, coords).rgb;
		
		float multiplier_x = 1.0;
		float multiplier_y = 1.0;
		
		if (shift.x != 0.0)
		{
			if (shift.x > 0.0)
				multiplier_x = smoothstep(1.0 - shift.x, 1.0 - shift.x - shift.x, coords.x);
			else
				multiplier_x = smoothstep(-shift.x, coords.x - shift.x, coords.x);
		}
		
		if (shift.y != 0.0)
		{
			if (shift.y > 0.0)
				multiplier_y = smoothstep(1.0 - shift.y, 1.0 - shift.y - shift.y, coords.y);
			else
				multiplier_y = smoothstep(-shift.y, coords.y - shift.y, coords.y);
		}
		
		shadow_v = max(shadow_c.r, max(shadow_c.g, shadow_c.b)) * multiplier_x * multiplier_y;
	}
	
	float3 color_dest = tex2D(ReShade::BackBuffer, texcoord).rgb;
	float color_dest_v = max(color_dest.r, max(color_dest.g, color_dest.b));
	
	color_dest = lerp(color_dest, float3(0.0, 0.0, 0.0), max(0.0, (shadow_v - color_dest_v) * transparency));
	
	return saturate(color_dest);
}

technique Shadows
{
	pass Shadows1
	{
		VertexShader = PostProcessVS;
		PixelShader = Shadows1;
	}
}