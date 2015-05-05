Shader "Custom/GLSLTest" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Texture Image", 2D) = "white" {}
		//_BumpMap ("Bump (RGB) Illumin (A)", 2D) = "bump" {}
	}
	SubShader {
	Pass{
		Tags{"LightMode" = "ForwardBase"}
		
		GLSLPROGRAM
		
		uniform vec4 _Color;
		uniform mat4 _Obj2World;
		uniform mat4 _World2Obj;
		uniform vec4 _WorldSpaceLightPos0;
		
		uniform vec4 _LightColor0;
		
		varying vec4 color;
		
		#ifdef VERTEX
		void main(){
			mat4 modelMat = _ Obj2World;
			mat4 modelMatInverse = _World2Obj;
			
			vec3 normalDir = normalize(
			 	vec3(vec4(gl_Normal,0.0)*modelMatInverse));
			vec3 lightDir = normalize(
			 	vec3(_WorldSpaceLightPos0));
			vec3 diffuseReflection = vec3(_LightColor0)*vec3(_Color)*
			  	max(0.0,dot(normalDir,lightDir));
			  
			color = vec4(diffuseReflection,1.0);
			gl_Postion = gl_ModleViewProjectionMatrix * gl_Vertex;
		
		}
		#endif
		
		#ifdef FRAGMENT
		void main(){
			gl_FragColor = color;
		}
		#endif
		
		ENDGLSL
		
		
	}
		Pass{
			GLSLPROGRAM
			
			uniform sampler2D _MainTex;
			
			varying vec4 TexCoord;
				#ifdef VERTEX
				void main()
				{
				TexCoord = gl_MultiTexCoord0;
				gl_postion = gl_ModelViewProjectionMatrix * gl_Vertex;
				}								
				#endif
				
				#ifdef FRAGMENT
				void main()
				{
				gl_FragColor = vec4(_Color.r,_Color.g,_Color.b,_Color.a);
				pass;
				}
				#endif
		ENDGLSL
				
		}
		
	} 
	FallBack "Custom/Testing"
}

