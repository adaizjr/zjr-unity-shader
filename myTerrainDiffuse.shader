// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "myshader/TerrainDiffuse" {
    Properties
    {
        //_FogC("Fog Color", Color) = (.65,.81,.94,.77)
        _Texture0 ("Texture 1", 2D) = "black" {}
        _Texture1 ("Texture 2", 2D) = "black" {}
        _Texture2 ("Texture 3", 2D) = "black" {}
        _Texture3 ("Texture 4", 2D) = "black" {}
        _UV ("UV", 2D) = "black" {}
        _Emission ("Emission", 2D) = "black" {}
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

            sampler2D _Texture0;
            sampler2D _Texture1;
            sampler2D _Texture2;
            sampler2D _Texture3;
            sampler2D _UV;
            sampler2D _Emission;
            float4 _Texture0_ST;
            float4 _Texture1_ST;
            float4 _Texture2_ST;
            float4 _Texture3_ST;
            float4 _UV_ST;
            float4 _Emission_ST;
            float4 _FogC;

            struct v2f
            {
                float4 pos:POSITION;
                float2 uv0:TEXCOORD0;
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
                //o.uv0 = TRANSFORM_TEX(v.texcoord, _Texture0);
                //o.uv1 = TRANSFORM_TEX(v.texcoord, _Texture1);
                //o.uv2 = TRANSFORM_TEX(v.texcoord, _Texture2);
                //o.uv3 = TRANSFORM_TEX(v.texcoord, _UV);
                o.uv0 = v.texcoord;

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
                o.fogData = saturate((400 - z)/50);


                return o;
            }

            half4 frag(v2f i):COLOR
            {    
                //fixed4 t0 = tex2D(_Texture0 , i.uv0.xy);
                //fixed4 t1 = tex2D(_Texture1 , i.uv1.xy);
                //fixed4 t2 = tex2D(_Texture2 , i.uv2.xy);
                //fixed4 t3 = tex2D(_UV , i.uv3.xy);

                fixed4 t0 = tex2D(_Texture0 , TRANSFORM_TEX(i.uv0,_Texture0));
                fixed4 t1 = tex2D(_Texture1 , TRANSFORM_TEX(i.uv0,_Texture1));
                fixed4 t2 = tex2D(_Texture2 , TRANSFORM_TEX(i.uv0,_Texture2));
                fixed4 t3 = tex2D(_Texture3 , TRANSFORM_TEX(i.uv0,_Texture3));
                fixed4 uv = tex2D(_UV , TRANSFORM_TEX(i.uv0,_UV));
                fixed4 em = tex2D(_Emission , TRANSFORM_TEX(i.uv0,_Emission));

                fixed4 texcolor = ((t0 * uv.x + t1 * uv.y + t2 * uv.z)*uv.w+t3*(1-uv.w))*fixed4(i.color, 1.0)+em;
                
        		_FogC= (.65,.81,.94,.77);
                // 阴影
                //float shadow = SHADOW_ATTENUATION(i)*.5+.5;
                //return fixed4(lerp(_FogC,texcolor,i.fogData).xyz*shadow,1);

                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                return fixed4(lerp(_FogC,texcolor,i.fogData).xyz*(atten*.5+.5),1);

                // 插值得到雾化后的颜色
                return fixed4(lerp(_FogC,texcolor,i.fogData).xyz,1);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}