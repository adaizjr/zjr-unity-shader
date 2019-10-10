# zjr-unity-shader

mobile terrain shader

unsupport mixed lighting

移动端地形shader，不支持静态烘焙。

支持一个方向光，自定义环境光，自定义线性雾化。

混合贴图RGBA通道，控制四张细节贴图混合，(tex0 * r + tex1 * g + tex2 * b) * a + tex3 * (1-a)
