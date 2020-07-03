Shader "zjrshader/TerrainDiffuse" {
    Properties
    {
        _Texture0 ("Texture 1", 2D) = "black" {}
        _Texture1 ("Texture 2", 2D) = "black" {}
        _Texture2 ("Texture 3", 2D) = "black" {}
        _Texture3 ("Texture 4", 2D) = "black" {}
        _UV ("UV", 2D) = "black" {}
        _Emission ("Emission", 2D) = "black" {}
        _SkyC("Sky Color", Color) = (.5,.5,.5,.5)
        _FogC("Fog Color", Color) = (.65,.81,.94,.77)
        _fogend("fog end",float)=450
        _fogstart("fog start",float)=400
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
            float4 _SkyC;
            float _fogend;
            float _fogstart;

            struct v2f
            {
                float4 pos:POSITION;
                float2 uv0:TEXCOORD0;
                //fixed3  SHLighting : COLOR;
                float fogData : TEXCOORD1;
                float3 worldPos : TEXCOORD2; 
                LIGHTING_COORDS(3, 4)
                
                fixed3 worldNormal : TEXCOORD5;  
                
                half2 uvLM : TEXCOORD4;
            };
            float4 _MainTex_ST;
            v2f vert(appdata_full  v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.texcoord;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);  
                
                // 计算物体到相机的距离。UnityObjectToViewPos：顶点到相机位置的向量；length():求向量的长度
                float z = length(UnityObjectToViewPos(v.vertex).xyz);
                // 计算雾化系数
                if (_fogend>_fogstart)
                    o.fogData = saturate((_fogend - z)/(_fogend-_fogstart));
                else
                    o.fogData = 1;
                
                o.uvLM = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                
                TRANSFER_VERTEX_TO_FRAGMENT(o);

                return o;
            }

            half4 frag(v2f i):COLOR
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;  
                fixed3 worldNormal = normalize(i.worldNormal);  
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 halfLambert = saturate(dot(worldNormal, worldLightDir)*.5 + 0.5);
                fixed3 diffuse = _LightColor0.rgb * halfLambert; 
                fixed3 SHLighting= ShadeSH9(float4(worldNormal,1)) ;

                fixed4 t0 = tex2D(_Texture0 , TRANSFORM_TEX(i.uv0,_Texture0));
                fixed4 t1 = tex2D(_Texture1 , TRANSFORM_TEX(i.uv0,_Texture1));
                fixed4 t2 = tex2D(_Texture2 , TRANSFORM_TEX(i.uv0,_Texture2));
                fixed4 t3 = tex2D(_Texture3 , TRANSFORM_TEX(i.uv0,_Texture3));
                fixed4 uv = tex2D(_UV , TRANSFORM_TEX(i.uv0,_UV));
                fixed4 em = tex2D(_Emission , TRANSFORM_TEX(i.uv0,_Emission));

                fixed4 texcolor = ((t0 * uv.x + t1 * uv.y + t2 * uv.z)*uv.w+t3*(1-uv.w));//+em;//*fixed4(i.color, 1.0);
                
                fixed3 lm = DecodeLightmap (UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM.xy))*SHLighting;          

                //_FogC= (.65,.81,.94,.77);

                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
                //float atten =LIGHT_ATTENUATION(i);
                return fixed4(lerp(_FogC,texcolor*(atten*diffuse+lm+ambient+_SkyC)+em,i.fogData).xyz,1);

                // 插值得到雾化后的颜色
                //return fixed4(lerp(_FogC,texcolor,i.fogData).xyz,1);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}