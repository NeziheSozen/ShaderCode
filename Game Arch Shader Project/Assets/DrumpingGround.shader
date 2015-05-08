// Use a Cook-Torrance  (with the bling phong for for the other part. )Model for a microfaceted BSDF.
// Holy shit i know what these words mean now.
// Sorta
Shader "Custom/CGTesting (Working in frag)" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_SpecColor("Spec Color", Color)= (1,1,1,1)
		_Shininess("Ohh... Shiny", Float) = 1.0
		
		_FresnelTerm("Fresnel Term (Refractive Index (0...1))", Float) = 1
		
		//_Glossiness("Gloss",Range(0,1))=0.5
		//_Metallic ("Metal",Range(0,1))= 0.0
	}
	SubShader {
	Pass{
	Tags{ "LightMode"="ForwardBase"}
		LOD 300
		
		CGPROGRAM
		//PBR lighting Model
		//#pragma surface surf Standard fullforwardshadows
		//Use for better looking lighting
		#pragma target 3.0
		
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		
		uniform sampler2D _MainTex;
		uniform float4 _LightColor0;
		uniform float4 _Color;
		uniform float4 _SpecColor;
		uniform float  _Shininess;
		uniform float  _FresnelTerm;
		
		uniform float  _f_0;
		struct vInput{
		//uvCoords should only be 2 thing, so a float2
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texCoord : TEXCOORD0;
		
		};
		
		struct vOuptut{
		float4 pos: SV_POSITION;
		float4 col: COLOR;
		float3 norm: NORMAL;
		float4 tex: TEXCOORD0;
		
		};
		//fixed4 is a vec4 in GLSL 
		
		//half _Glossiness;
		//half _Metallic;
		
	
		vOuptut vert (vInput input)
		{
			vOuptut output;
			float4x4  modelMat = _Object2World;
			float4x4  modelMatInv = _World2Object;
			output.norm = normalize(
				mul(float4(input.normal,0.0),modelMatInv).xyz);
			
			
			
			//output.col = float4(diffuseReflection 
			//+ ambientLighting + specReflection,0.0);
			output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
			output.tex = input.texCoord;
			return output;
		
		}
		
		float4 frag( vOuptut input):COLOR
		{
			
			float3 viewDir = normalize(_WorldSpaceCameraPos - 
				mul(_Object2World, input.pos).xyz);
			float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
			
			float3 diffuseReflection  = _LightColor0.rgb * _Color.rgb
				 * max(0.0,dot(input.norm,lightDir));
			
			
			float attenuation = 1.0; //only one light to worry about.
			
			float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb *_Color.rbg;
			
			float3 specReflection;
			if(dot(input.norm,lightDir)<0.0){
			specReflection = float3(0.0,0.0,0.0);
			}
			else{
			specReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb
			*pow(max(0.0,dot(reflect(-lightDir,input.norm),viewDir)),_Shininess);			
			}
			float4 finalCol = float4(diffuseReflection 
			+ ambientLighting + specReflection,0.0);
			float4 tex =  tex2D(_MainTex, input.tex.xy) *finalCol;
			return tex;
		}
		ENDCG
	 }
}
	
	FallBack "Diffuse"
}

