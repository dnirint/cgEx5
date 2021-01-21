// Checks for an intersection between a ray and a sphere
// The sphere center is given by sphere.xyz and its radius is sphere.w
void intersectSphere(Ray ray, inout RayHit bestHit, Material material, float4 sphere)
{
    float r = sphere.w;
    float3 center = sphere.xyz;
    float3 rayToOriginDirection = ray.origin-center;

    float A = 1;
    //B = 2(o-c)d
    float B = 2 * dot(rayToOriginDirection,ray.direction);
    //C = (o-c)(o-c)-r^2
    float C = dot(rayToOriginDirection,rayToOriginDirection) - pow(r,2);
    
    float D = dot(B,B)-4*(dot(A,C));

    if (D <= 0) // no intersection
    {
        return;
    }
    float t = (-B - sqrt(D))/(2);
    if (t < bestHit.distance) // found a better hit
    {
        bestHit.distance = t;
        bestHit.position = ray.origin + t * ray.direction;
        bestHit.normal = bestHit.position - center;
        bestHit.material = material;
    }
    
    
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
void intersectPlane(Ray ray, inout RayHit bestHit, Material material, float3 c, float3 n)
{
	float3 d = ray.direction;
	float3 o = ray.origin;
    if (dot(d, n) == 0)
	{
		return;
	}
	float t = (-dot((o-c), n)) / (dot(d, n));
	if (t < bestHit.distance) // found a better hit
    {
		bestHit.distance = t;
        bestHit.position = ray.origin + t * ray.direction;
        bestHit.normal = n;
        bestHit.material = material;
	}
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
// The material returned is either m1 or m2 in a way that creates a checkerboard pattern 
void intersectPlaneCheckered(Ray ray, inout RayHit bestHit, Material m1, Material m2, float3 c, float3 n)
{
    // Your implementation
}


// Checks for an intersection between a ray and a triangle
// The triangle is defined by points a, b, c
void intersectTriangle(Ray ray, inout RayHit bestHit, Material material, float3 a, float3 b, float3 c)
{
    // Your implementation
}


// Checks for an intersection between a ray and a 2D circle
// The circle center is given by circle.xyz, its radius is circle.w and its orientation vector is n 
void intersectCircle(Ray ray, inout RayHit bestHit, Material material, float4 circle, float3 n)
{
    // Your implementation
}


// Checks for an intersection between a ray and a cylinder aligned with the Y axis
// The cylinder center is given by cylinder.xyz, its radius is cylinder.w and its height is h
void intersectCylinderY(Ray ray, inout RayHit bestHit, Material material, float4 cylinder, float h)
{
    // Your implementation
}
