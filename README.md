# zjr-unity-shader

terrain shader

支持烘焙，阴影，自定义线性雾化，自定义环境光，1个动态方向光，不支持其他动态光源。

混合贴图RGBA通道，控制四张细节贴图混合，(tex0 * r + tex1 * g + tex2 * b) * a + tex3 * (1-a)
