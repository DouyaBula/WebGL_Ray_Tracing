# 北航2023秋计算机图形学

本仓库上传了北航计算机学院本科《计算机图形学》大作业可选项目之一——使用原生WebGL实现简易光线追踪。此外还上传了期末课程报告，最后的期末综评是95分。

仅供参考，不要抄袭，任课教师会严查每一份作业。



## 运行说明

因为需要加载纹理图片, **务必使用VS Code的Live Server插件打开网页**. 直接打开html文件会出现加载文件跨域报错的问题。



## 目录结构

以下是文件的目录结构: 

```bash
├─RayTracing
│  │  fragmentShader.glsl
│  │  image.png
│  │  index.html
│  │  render.js
│  │  style.css
│  │  vertexShader.glsl
│  │
│  └─lib
│          webgl-utils.js
```

其中fragmentShader.glsl是片元着色器代码; vertexShader.glsl是顶点着色器代码; image.png是带有学号和姓名的纹理图片; index.html是网页html文件, 里面集成了着色器代码; render.js是网页js文件; style.css是网页css文件; lib文件夹里使用了webgl-utils.js库, 用于简化重复性代码.  

