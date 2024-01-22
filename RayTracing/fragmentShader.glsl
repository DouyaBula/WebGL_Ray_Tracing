precision mediump float;
varying vec2 viewPortPosition;
uniform sampler2D uImage;
uniform float x1;
uniform float y1;
uniform float z1;
uniform float s1;
uniform float x2;
uniform float y2;
uniform float z2;
uniform float s2;
uniform float x3;
uniform float y3;
uniform float z3;
uniform float s3;
uniform float x4;
uniform float y4;
uniform float z4;
uniform float s4;
uniform float c1;
uniform float c2;
uniform float c3;
uniform float c4;
struct Camera {
    vec3 viewPortCenter;
    vec3 up;
    float distance;
};

        /* 视图大小: 512 * 512 */

        /* 坐标系
        ^ y
        |     ↗ z
        |   /
        | /
        .-----------> x
        */

        /* 渲染参数 */
const float INF = 1e10;
const float epsilon = 0.01;
const int iterations = 16;
const float exposure = 1e-2;
const float gamma = 2.2;
const float intensity = 110.0;
const vec3 ambient = vec3(0.9, 0.8, 0.8) * intensity / gamma;
const int num_spheres = 3;
        // 伪材质
vec3 texture[4];

        /* 数据结构 */
struct Ray {
    vec3 origin;
    vec3 direction;
};

struct ParaLight {
    vec3 color;
    vec3 direction;
};

struct Material {
    vec3 color;
    float diffuse;
    float specular;
};
const Material tex = Material(vec3(-1.0, -1.0, -1.0), 1.0, 0.0);

struct Intersect {
    float len;
    vec3 normal;
    Material material;
};
const Intersect miss = Intersect(0.0, vec3(0.0), Material(vec3(0.0), 0.0, 0.0));

struct Sphere {
    float radius;
    vec3 position;
    Material material;
};

struct Plane {
    vec3 normal;
    Material material;
};

struct CubePlane {
    vec3 normal;
    vec3 center;
};

struct Cube {
    vec3 position;
    float radius;
    Material material;
};

        /* 场景 */

        // 平行光
ParaLight light;
        // 球体
Sphere spheres[num_spheres];
        // 平面(地板)
Plane plane;
        // 立方体
Cube cube;

        /* 函数 */

        // 判断是否命中
bool isMiss(Intersect intersection) {
    return intersection.len == miss.len && intersection.normal == miss.normal && intersection.material.color == miss.material.color && intersection.material.diffuse == miss.material.diffuse && intersection.material.specular == miss.material.specular;
}

        // 判断是否为纹理材质
bool isTexture(Material material) {
    return material.color == tex.color && material.diffuse == tex.diffuse && material.specular == tex.specular;
}

        // 线球相交
Intersect intersect(Ray ray, Sphere sphere) {
    vec3 oc = sphere.position - ray.origin;
    float l = dot(ray.direction, oc);
    float det = pow(l, 2.0) - dot(oc, oc) + pow(sphere.radius, 2.0);
    if(det < 0.0)
        return miss;
    float len = l - sqrt(det);
    if(len < 0.0)
        len = l + sqrt(det);
    if(len < 0.0)
        return miss;
    return Intersect(len, (ray.origin + len * ray.direction - sphere.position) / sphere.radius, sphere.material);
}

        // 线面相交, 本场景中只有地板, 默认中心位于原点
Intersect intersect(Ray ray, Plane plane) {
    float len = -dot(ray.origin, plane.normal) / dot(ray.direction, plane.normal);
    if(len < 0.0)
        return miss;
    return Intersect(len, plane.normal, plane.material);
}

        // 线立方体相交
Intersect intersect(Ray ray, Cube cube) {
            // 获取AABB包围盒的左, 右, 上, 下, 前, 后面
    CubePlane planes[6];
    planes[0] = CubePlane(vec3(-1.0, 0.0, 0.0), vec3(cube.position.x - cube.radius, cube.position.y, cube.position.z));
    planes[1] = CubePlane(vec3(1.0, 0.0, 0.0), vec3(cube.position.x + cube.radius, cube.position.y, cube.position.z));
    planes[2] = CubePlane(vec3(0.0, 1.0, 0.0), vec3(cube.position.x, cube.position.y + cube.radius, cube.position.z));
    planes[3] = CubePlane(vec3(0.0, -1.0, 0.0), vec3(cube.position.x, cube.position.y - cube.radius, cube.position.z));
    planes[4] = CubePlane(vec3(0.0, 0.0, -1.0), vec3(cube.position.x, cube.position.y, cube.position.z - cube.radius));
    planes[5] = CubePlane(vec3(0.0, 0.0, 1.0), vec3(cube.position.x, cube.position.y, cube.position.z + cube.radius));

            // 判断是否与包围盒相交
    float t_all[6];
    float t_min[3];
    t_min[0] = INF;
    t_min[1] = INF;
    t_min[2] = INF;
    float t_max[3];
    t_max[0] = -INF;
    t_max[1] = -INF;
    t_max[2] = -INF;
    for(int i = 0; i < 6; i++) {
        vec3 po = planes[i].center - ray.origin;
        float t = dot(po, planes[i].normal) / dot(ray.direction, planes[i].normal);
        t_all[i] = t;
        t_min[i / 2] = min(t_min[i / 2], t);
        t_max[i / 2] = max(t_max[i / 2], t);
    }
    float t_enter = max(max(t_min[0], t_min[1]), t_min[2]);
    float t_exit = min(min(t_max[0], t_max[1]), t_max[2]);
    vec3 normal;
    if(t_enter < t_exit && t_exit > 0.0) {
        for(int i = 0; i < 6; i++) {
            if(t_all[i] == t_enter) {
                normal = planes[i].normal;
                break;
            }
        }
        return Intersect(t_enter, normal, cube.material);
    } else {
        return miss;
    }
}

        // 检测交点
Intersect trace(Ray ray) {
    Intersect intersection = miss;
    float len = INF;
            // 依次检测各个物体
            // 检测平面
    Intersect planeInt = intersect(ray, plane);
    if(!isMiss(planeInt) && planeInt.len < len) {
        len = planeInt.len;
        intersection = planeInt;
    }
            // 检测立方体
    Intersect cubeInt = intersect(ray, cube);
    if(!isMiss(cubeInt) && cubeInt.len < len) {
        len = cubeInt.len;
        intersection = cubeInt;
    }
            // 检测球体们
    for(int i = 0; i < num_spheres; i++) {
        Intersect sphereInt = intersect(ray, spheres[i]);
        if(!isMiss(sphereInt) && sphereInt.len < len) {
            len = sphereInt.len;
            intersection = sphereInt;
        }
    }
    return intersection;
}

        // 求纹理坐标
vec2 getTexture(vec3 p, Cube cube) {
            // 先判断落在了哪个面上
    float left_x = cube.position.x - cube.radius;
    float right_x = cube.position.x + cube.radius;
    float up_y = cube.position.y + cube.radius;
    float down_y = cube.position.y - cube.radius;
    float front_z = cube.position.z - cube.radius;
    float back_z = cube.position.z + cube.radius;
            // 然后判断在该面上的哪个位置
    float width = 2.0 * cube.radius;
    if(abs(p.x - left_x) < epsilon || abs(p.x - right_x) < epsilon) {
                // 左面或右面
        return vec2((p.z - front_z) / width, (p.y - down_y) / width);
    }
    if(abs(p.y - up_y) < epsilon || abs(p.y - down_y) < epsilon) {
                // 上面或下面
        return vec2((p.x - left_x) / width, (p.z - front_z) / width);
    }
    if(abs(p.z - front_z) < epsilon || abs(p.z - back_z) < epsilon) {
                // 前面或后面
        return vec2((p.x - left_x) / width, (p.y - down_y) / width);
    }
}

        // 发射光线
vec3 emit(Ray ray) {
    vec3 color = vec3(0.0, 0.0, 0.0);
    vec3 fresnel = vec3(0.0, 0.0, 0.0);
    vec3 mask = vec3(1.0, 1.0, 1.0);
    for(int i = 0; i <= iterations; ++i) {
        Intersect hit = trace(ray);
        if(!isMiss(hit)) {
                    // 菲涅尔方程近似计算
            vec3 r0 = hit.material.color * hit.material.specular;
            float hv = clamp(dot(hit.normal, -ray.direction), 0.0, 1.0);
            fresnel = r0 + (1.0 - r0) * pow(1.0 - hv, 5.0);
            mask *= fresnel;

                    // 若可见，则计算漫反射
            Ray shadow = Ray(ray.origin + hit.len * ray.direction + epsilon * light.direction, light.direction);
            if(isMiss(trace(shadow))) {
                if(isTexture(hit.material)) {
                            // 纹理材质
                    vec3 texColor;
                            // 判断纹理坐标, 一定在cube上
                    vec3 p = ray.origin + hit.len * ray.direction;
                    vec2 texCoord = getTexture(p, cube);
                    texColor = texture2D(uImage, texCoord).rgb;
                    color += clamp(dot(hit.normal, light.direction), 0.0, 1.0) * light.color * texColor * hit.material.diffuse * (1.0 - fresnel) * mask / fresnel;
                } else {
                            // 普通材质
                    color += clamp(dot(hit.normal, light.direction), 0.0, 1.0) * light.color * hit.material.color * hit.material.diffuse * (1.0 - fresnel) * mask / fresnel;
                }
            }

                    // 循环追踪反射光线
            vec3 reflection = reflect(ray.direction, hit.normal);
            ray = Ray(ray.origin + hit.len * ray.direction + epsilon * reflection, reflection);
        } else {

                    // 若未命中，则补充环境光
            vec3 spotlight = vec3(1e6) * pow(abs(dot(ray.direction, light.direction)), 250.0);
            color += mask * (ambient + spotlight);
            break;
        }
    }
    return color;
}

        // 初始化
void scene() {
    texture[0] = vec3(0.0, 0.0, 0.0);
    texture[1] = vec3(1.0, 1.0, 1.0);
    texture[2] = vec3(0.0, 0.0, 1.0);
    texture[3] = vec3(1.0, 1.0, 0.0);
    light = ParaLight(vec3(1.0, 1.0, 1.0) * intensity, normalize(vec3(0.0 + c1 * 0.03, 1.0, -1.0)));
    plane = Plane(vec3(0, 1, 0), Material(vec3(0.7, 0.7, 1.0), 1.0, 0.0));
    spheres[0] = Sphere(30.0 + s1 < 1.0 ? 1.0 : 30.0 + s1, vec3(-100.0 + x1, 30.0 + y1, -120.0 + z1), Material(vec3(0.6, 0.2, 0.2), 1.0, 0.001));
    spheres[1] = Sphere(50.0 + s2 < 1.0 ? 1.0 : 50.0 + s2, vec3(0.0 + x2, 50.0 + y2, 6.0 + z2), Material(vec3(1.0, 0.2, 0.0), 1.0, 0.5));
    spheres[2] = Sphere(30.0 + s3 < 1.0 ? 1.0 : 30.0 + s3, vec3(20.0 + x3, 30.0 + y3, -80.0 + z3), Material(vec3(0.8, 0.1, 0.8), 0.1, 0.0));
    cube = Cube(vec3(70.0 + x4, 20.0 + y4, -120.0 + z4), 20.0 + s4 < 1.0 ? 1.0 : 20.0 + s4, tex);
}

void main() {
    scene();
    Camera camera = Camera(vec3(0.0 + c2, 50.0 + c3 < 1.0 ? 1.0 : 50.0 + c3, 0.0 + c4), vec3(0.0, 1.0, 0.0), 256.0);
    Ray ray;
    ray.origin = vec3(camera.viewPortCenter.x, camera.viewPortCenter.y, camera.viewPortCenter.z - camera.distance);
    ray.direction = normalize(vec3(camera.viewPortCenter.x + viewPortPosition.x, camera.viewPortCenter.y + viewPortPosition.y, camera.viewPortCenter.z) - ray.origin);
    gl_FragColor = vec4(pow(emit(ray) * exposure, vec3(1.0 / gamma)), 1.0);
}