// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'



Shader "Custom/MyShader" {

	//Properties will appear on the inspector in unity editor. Usually, it could be color, texture map, normal map, etc.
	//However, I don't need any property, so I leave it blank.
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_RampTex ("Ramp Tex", 2D) = "white" {}
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloass", Range(8.0, 256)) = 20
	}

	// A shader can contain several SubShaders. If GPU support, the first SubShader will be used. If GPU don't support, the unity will try next SubShader. 
	//So, actually, only one of the SubShaders will be used. Therefore, it's good to write subshaders as many as possible to adapt on different computers.
	SubShader {

		//A SubShader can contain several Passes and every pass will be used. I consider a Pass as a layer in Photoshop.
		Pass{
			Tags{
				"LightMode" = "ForwardBase"
			}
			//CG is one of shader languages, used in DirectX originally.
			CGPROGRAM

			//tell unity 'vert' is vertex shader 
			#pragma vertex vert

			//tell unity 'frag' is fragment shader
			#pragma fragment frag


			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Specular;
			float _Gloss;

			//define a structure.
			//'a2v'means 'application to vertex shader'
			struct a2v{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float4 texcoord: TEXCOORD0;
			};

			//'v2f' means 'vertex shader to fragment shader'
			struct v2f{
				float4 pos: SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				fixed2 uv: TEXCOORD2;
			};
 
			//Here is my vertex Shader
			v2f vert(a2v v) {
				v2f o;
				//transfer vertex position from world coordinates to screen clip coordinates
				o.pos = UnityObjectToClipPos (v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);

				//return vertex position and color
				return o;
			}

			//Here is my fragment shader
			fixed4 frag(v2f i) : SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed halfLambert = 0.5*dot(worldNormal, worldLightDir) + 0.5;
				fixed3 diffuseColor = tex2D(
				_RampTex, 
				fixed2(halfLambert, halfLambert)
				).rgb * _Color.rgb;

				fixed3 diffuse = _LightColor0.rgb * diffuseColor;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				return fixed4(ambient + specular + diffuse, 1.0);
			}

			ENDCG
		}
	}
	
}
