Shader "Custom/Outline" {
    Properties {
        _OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineIntensity ("Outline Intensity", Float) = 1.0
        _DepthRadius ("Depth Radius", Float) = 0.01
    }
    
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _DepthRadius;
            float4 _OutlineColor;
            float _OutlineIntensity;
            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
            UNITY_DECLARE_TEX2D(_CameraOpaqueTexture);

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeScreenPos(o.vertex);
                COMPUTE_EYEDEPTH(o.screenPos.z);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float getDepth(v2f i, float4 offset) {
                float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos + offset)));
                return sceneZ - i.screenPos.z;
            }

            float getMax(float4 values) {
                float maxValue = 0;
                for (int i = 0; i < 4; i++) maxValue = max(maxValue, values[i]);
                return maxValue;
            }

            fixed4 frag (v2f i) : SV_Target {
                // depth
                // float4 depthOffset = float4(0.1, 0.1, 0, 0);
                // float depth = getDepth(i, depthOffset);
                float4 adjacentDepths = 0;
                float4 localDepth = getDepth(i, 0);
                adjacentDepths[0] = getDepth(i, float4(-_DepthRadius, 0, 0, 0));
                adjacentDepths[1] = getDepth(i, float4(_DepthRadius, 0, 0, 0));
                adjacentDepths[2] = getDepth(i, float4(0, -_DepthRadius, 0, 0));
                adjacentDepths[3] = getDepth(i, float4(0, _DepthRadius, 0, 0));

                // screen color
                float2 screenPosition = i.screenPos.xy / i.screenPos.w;
                fixed4 screenColor = UNITY_SAMPLE_TEX2D(_CameraOpaqueTexture, screenPosition);

                // mixing
                float depth = max(adjacentDepths[0], getMax(adjacentDepths));
                fixed4 col = (depth > 0.1) ? _OutlineColor * _OutlineIntensity : screenColor;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
