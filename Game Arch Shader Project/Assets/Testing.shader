// Use a Cook-Torrance  (with the bling phong for for the other part. )Model for a microfaceted BSDF.
// Holy shit i know what these words mean now.
// Sorta
Shader "Custom/CGTesting (Working)" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_SpecColor("Spec Color", Color)= (1,1,1,1)
		_Shininess("Shiny Term", Range(1,10)) = 1.0
		
		_FresnelTerm("Fresnel Term (Refractive Index)", Range(1,20)) = 10
		_Roughness("Roughness",Range(0.01,1))=0.5
		
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
		uniform float  _Roughness;
		const float PI = 3.14159;
		
		
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
			float3 normDir = normalize(
				mul(float4(input.normal,0.0),modelMatInv).xyz);
			float3 viewDir = normalize(_WorldSpaceCameraPos - 
				mul(modelMat, input.vertex).xyz);
			float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
			
			float3 diffuseReflection  = _LightColor0.rgb * _Color.rgb
				 * max(0.0,dot(normDir,lightDir));
			float alpha = _Roughness * _Roughness;
			float3 m = _Roughness; 
			//Half Vector
			float3 HalfV = normalize(lightDir+viewDir);
					
			//Lots of dot products to make doing the calcs simpler
			float NdotL =max( dot(normDir, lightDir),0.0);
			float NdotV = max( dot(normDir, viewDir),0.0);
			float NdotM = dot(normDir,m);
			float VdotH = dot( viewDir,HalfV);
			float NdotH = dot(normDir,HalfV);
			float LdotH = dot(lightDir,HalfV);
			
			//GGX terms to make calc cleaner
			//Distribution terms
			float alpha_1 = pow(alpha,2.0)-1.0;
			float alpha_2 = pow(alpha,2.0);
			float GGX = alpha_2/PI*pow((pow(NdotM,2.0)*alpha_1+1.0),2.0);
			float Cos2 = pow(NdotH,2);
			float Tan2 = 1.0-Cos2/Cos2;
			float3 GGX2 = (1.0/PI) * pow(_Roughness/Cos2*(alpha_2+Tan2),2);
			float BP_m = 2.0/alpha_2 - 2.0;
			float BP = (BP_m+2.0) * pow(max(NdotH,0.0),BP_m)/(2.0*PI);
			//Geometric shadowing term
			float Neumann = NdotL*NdotV/max(NdotL,NdotV);
			float Implicit = NdotL*NdotV;
			float CT = min(min(2.0*NdotH * NdotV / VdotH,2.0*NdotH*NdotL/VdotH),1.0);
			//Fresnel term
			float f0 = pow((1.0-_FresnelTerm/1.0+_FresnelTerm),2.0);
			float Fresnel = f0 + ((1.0-f0)*pow(NdotL,5.0));
			
			float attenuation = 1.0; //only one light to worry about.
			
			float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb *_Color.rbg;
			
			float3 BRDF = (BP * Fresnel * CT)/(4 * NdotL * NdotV);
			
			float3 specReflection;
			if(dot(normDir,lightDir)<0.0){
			specReflection = float3(0.0,0.0,0.0);
			}
			else{
			specReflection = attenuation  * _LightColor0.rgb * _SpecColor.rgb
			*pow(max(0.0,dot(reflect(-lightDir,normDir),viewDir)),_Shininess) ;			
			
			}
			float3 color_spec = NdotL *BRDF *_SpecColor.rgb;
			float3 color_diff = NdotL *(1.0 - Fresnel) * diffuseReflection * _LightColor0;
			//output.col = float4(color_diff + color_spec,1);
			
			output.col = float4(diffuseReflection 
			+ ambientLighting + specReflection,0.0);
			output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
			output.tex = input.texCoord;
			return output;
		
		}
		
		float4 frag( vOuptut input):COLOR
		{
			return tex2D(_MainTex, input.tex.xy) *input.col;
		}
		ENDCG
	 }
}
	
	FallBack "Diffuse"
}

