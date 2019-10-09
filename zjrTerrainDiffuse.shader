Shader "zjrshader/TerrainDiffuse" {
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)

    	//四张贴图
        _Texture0 ("Texture 1", 2D) = "black" {}
        _Texture1 ("Texture 2", 2D) = "black" {}
        _Texture2 ("Texture 3", 2D) = "black" {}
        _Texture3 ("Texture 4", 2D) = "black" {}
        //贴图的混合
        _Blend ("Blend", 2D) = "black" {}
        //自发光颜色
        _Emission ("Emission", 2D) = "black" {}
        
        _FogDistant("Fog Distant", float) = 400
        _FogChange("Fog Change", float) = 50
        _FogC("Fog Color", Color) = (.65,.81,.94,.77)
    }
    SubShader
    {

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
        	Tags{"RenderType"="Opaque"  "LightMode"="ForwardBase" }
        	
        	CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            float4 _Color;
            sampler2D _Texture0;
            sampler2D _Texture1;
            sampler2D _Texture2;
            sampler2D _Texture3;
            sampler2D _Blend;
            sampler2D _Emission;
            float4 _Texture0_ST;
            float4 _Texture1_ST;
            float4 _Texture2_ST;
            float4 _Texture3_ST;
            float4 _Blend_ST;
            float4 _Emission_ST;
            float4 _FogC;
            float _FogDistant;
            float _FogChange;

            struct v2f
            {
                float4 pos:POSITION;
                float2 uv:TEXCOORD0;
                float3 color : COLOR;
                SHADOW_COORDS(1)
                float fogData : TEXCOORD2;
                float3 worldPos : TEXCOORD3; 
            };
            float4 _MainTex_ST;
            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                o.pos = UnityObjectToClipPos(v.vertex);

                // 获取光源世界坐标系中的方向,并进行归一化处理
                fixed3 world_light = normalize(_WorldSpaceLightPos0.xyz);

                // 获取法线世界坐标系中的方向,并进行归一化处理
                fixed3 world_normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                // 兰伯特漫反射计算公式为:光照颜色和强度变量(_LightColor0) * 漫反射系数(_Diffuse) * 光源方向(_WorldSpaceLightPos0)与法线方向(normal)的非负值点积
                fixed3 diffuse = _LightColor0.rgb  * saturate(dot(world_normal, world_light));

                // 最终颜色为:环境光和漫反射插值
                o.color =  diffuse+.5;//UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);

				// 计算物体到相机的距离。UnityObjectToViewPos：顶点到相机位置的向量；length():求向量的长度
                float z = length(UnityObjectToViewPos(v.vertex).xyz);
                // 计算雾化系数
                o.fogData = saturate((_FogDistant - z)/_FogChange);


                return o;
            }

            half4 frag(v2f i):COLOR
            {
            	fixed4 t0 = tex2D(_Texture0 , TRANSFORM_TEX(i.uv,_Texture0));
                fixed4 t1 = tex2D(_Texture1 , TRANSFORM_TEX(i.uv,_Texture1));
                fixed4 t2 = tex2D(_Texture2 , TRANSFORM_TEX(i.uv,_Texture2));
                fixed4 t3 = tex2D(_Texture3 , TRANSFORM_TEX(i.uv,_Texture3));
                fixed4 blend = tex2D(_Blend , TRANSFORM_TEX(i.uv,_Blend));
                fixed4 em = tex2D(_Emission , TRANSFORM_TEX(i.uv,_Emission));

                fixed4 texcolor = fixed4((((t0 * blend.x + t1 * blend.y + t2 * blend.z)*blend.w+t3*(1-blend.w))*fixed4(i.color, 1.0)).xyz,1)+em;
                
                // 阴影
                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                fixed4 tt = (atten*.5+.5);
                tt =fixed4(tt.x,tt.y,tt.z, 1);
                tt = texcolor*tt*_Color;
                return lerp(_FogC,tt,i.fogData);
				//return lerp(_FogC,texcolor*_Color,i.fogData);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}