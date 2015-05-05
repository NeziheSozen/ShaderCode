Shader "Custom/CGTesting" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Glossiness("Gloss",Range(0,1))=0.5
		_Metallic ("Metal",Range(0,1))= 0.0
	}
	SubShader {
	
	Tags{"RenderType" = "Opaque"}
		LOD 300
		
		CGPROGRAM
		//PBR lighting Model
		#pragma surface surf Standard fullforwardshadows
		//Use for better looking lighting
		#pragma target 3.0
		
		//#pragma vertex vert
		//#pragma fragment frag
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		
		struct Input{
		//uvCoords should only be 2 thing, so a float2
			float2 uv_MainTex;
		};
		//fixed4 is a vec4 in GLSL 
		fixed4 _Color;
		half _Glossiness;
		half _Metallic;
		
		void surf (Input input, inout SurfaceOutputStandard output){
		fixed4 c = tex2D(_MainTex,input.uv_MainTex)* _Color;
		output.Albedo = c.rgb; 
		output.Alpha = c.a;
		output.Metallic = _Metallic;
		output.Smoothness = _Glossiness;
		}
		
		//float4 vert(appdata_base v): POSITION{
		//return mul(UNITY_MATRIX_MVP,v.vertex);
		//}
		//fixed4 frag(v2f_img image):SV_TARGET{
		//fixed4 output =  tex2D(_MainTex,image.uv)*_Color;
		//output.Metallic = _Metallic;
		//output.Smoothness = _Glossiness;
		//return output;
		//}
		
		ENDCG
	} 
	
	//FallBack "Diffuse"
}

