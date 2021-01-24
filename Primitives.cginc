// Checks for an intersection between a ray and a sphere
// The sphere center is given by sphere.xyz and its radius is sphere.w
void intersectSphere(Ray ray, inout RayHit bestHit, Material material, float4 sphere)
{
    float r = sphere.w;
    float3 center = sphere.xyz;
    float3 rayToOriginDirection = ray.origin-center;

    float A = 1;
    float B = 2 * dot(rayToOriginDirection,ray.direction);
    float C = dot(rayToOriginDirection,rayToOriginDirection) - pow(r,2);
    
    float D = B*B-4*A*C;
    if (D <= 0) // no intersection
    {
        return;
    }
    float t = (-B - sqrt(D))/(2);
	if (t <= 0)
	{
		return;
	}
	
    if (t < bestHit.distance) // found a better hit
    {
        bestHit.distance = t;
        bestHit.position = ray.origin + t * ray.direction;
        bestHit.normal = normalize(bestHit.position - center);
        bestHit.material = material;
    }
    
    
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
void intersectPlane(Ray ray, inout RayHit bestHit, Material material, float3 c, float3 n)
{
	float3 d = normalize(ray.direction);
	float3 o = ray.origin;
    float d_dot_n = dot(d,n);
    if (d_dot_n == 0)
	{
		return;
	}
	float t = (-dot((o-c), n)) / (d_dot_n);
	if (t <= 0)
	{
		return;
	}
	if (t < bestHit.distance) // found a better hit
    {
		bestHit.distance = t;
        bestHit.position = ray.origin + t * normalize(ray.direction);
        bestHit.normal = normalize(n);
        bestHit.material = material;
	}
}

// Checks for an intersection between a ray and a plane
// The plane passes through point c and has a surface normal n
// The material returned is either m1 or m2 in a way that creates a checkerboard pattern 
void intersectPlaneCheckered(Ray ray, inout RayHit bestHit, Material m1, Material m2, float3 c, float3 n)
{
    intersectPlane(ray, bestHit, m2, c, n);
    float bestHitX = bestHit.position.x;
    float bestHitZ = bestHit.position.z;
    float xfloor = floor(bestHitX);
    float zfloor = floor(bestHitZ);
    float xFrac = bestHitX - xfloor;
    float zFrac = bestHitZ - zfloor;
    if (xFrac<0.5 && zFrac<0.5 || xFrac>0.5 && zFrac>0.5)
    {
        bestHit.material = m1;
    }
}


// Checks for an intersection between a ray and a triangle
// The triangle is defined by points a, b, c
void intersectTriangle(Ray ray, inout RayHit bestHit, Material material, float3 a, float3 b, float3 c)
{
    float3 ba = normalize(b-a);
    float3 ca = normalize(c-a);
    float3 normal = normalize(cross(ba,ca));
    RayHit planeHit = CreateRayHit();
    
    intersectPlane(ray, planeHit, material, a, normal);
    if (isinf(planeHit.distance)) // we didn't hit the plane that contains the triangle
    {
        return;
    }
    // check if the hit point is inside the triangle
    float c1 = dot(cross((b-a),(planeHit.position-a)),normal);
    float c2 = dot(cross((c-b),(planeHit.position-b)),normal);
    float c3 = dot(cross((a-c),(planeHit.position-c)),normal);
    if (c1>=0 && c2>=0 && c3>=0) // the hitpoint is indeed inside the triangle
    {
        
        if (planeHit.distance < bestHit.distance)
        {
            bestHit.distance = planeHit.distance;
            bestHit.position = planeHit.position;
            bestHit.normal = normal;
            bestHit.material = material;
        }
    }



}


// Checks for an intersection between a ray and a 2D circle
// The circle center is given by circle.xyz, its radius is circle.w and its orientation vector is n 
void intersectCircle(Ray ray, inout RayHit bestHit, Material material, float4 circle, float3 n)
{
	RayHit planeHit = CreateRayHit();
	float radius  = circle.w;
    intersectPlane(ray, planeHit, material, radius, n);
	if (isinf(planeHit.distance)) // we didn't hit the plane that contains the circle
    {
        return;
    }
	
	float distanceToCenter = length(planeHit.position - circle.xyz);
	if (distanceToCenter < radius) // the hitpoint is indeed inside the circle
    {
        if (planeHit.distance < bestHit.distance) //nothing is in front of the circle 
        {
            bestHit.distance = planeHit.distance;
            bestHit.position = planeHit.position;
            bestHit.normal = n;
            bestHit.material = material;
        }
    }
}


// Checks for an intersection between a ray and a cylinder aligned with the Y axis
// The cylinder center is given by cylinder.xyz, its radius is cylinder.w and its height is h
void intersectCylinderY(Ray ray, inout RayHit bestHit, Material material, float4 cylinder, float h)
{
	float radius = cylinder.w;
	float4 topCap = cylinder;
	topCap.y = topCap.y + (h/2);
	float4 bottomCap = cylinder;
	bottomCap.y = bottomCap.y - (h/2);
	float3 upDirection = float3(0, 1, 0);
	
	// check intersection with caps
	intersectCircle(ray, bestHit, material, topCap, upDirection);
	intersectCircle(ray, bestHit, material, bottomCap, -upDirection);	
	
	// check intersection with cylinder
	float dx = ray.direction.x;
	float dz = ray.direction.z;
	float ox = ray.origin.x;
	float oz = ray.origin.z;
	float cx = cylinder.x;
	float cz = cylinder.z;
	
	float a = dx * dx + dz * dz;
	float b = 2 * (ox * dx - cx * dx + oz * dz - cz * dz);
	float c = ox * ox + cx * cx + oz * oz + cz * cz - 2 * (ox * cx + oz * cz) - radius;
	
	float discriminant = b * b - 4 * a * c;
	if (discriminant > 0) // there is intersection with infinite cylinder
	{
		float t = (-b - sqrt(discriminant))/ (2 * a);
		float3 cylinderHitLocation = ray.origin + ray.direction * t;
		// check intersection with finite cylinder
		if (abs(cylinderHitLocation.y - cylinder.y) < h)
		{
			if (t < bestHit.distance) 
			{
				bestHit.distance = t;
				bestHit.position = cylinderHitLocation;
				bestHit.normal = normal;
				bestHit.material = material;
			}
		}
	}
}
