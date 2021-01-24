// Implements an adjusted version of the Blinn-Phong lighting model
float3 blinnPhong(float3 n, float3 v, float3 l, float shininess, float3 albedo)
{
    float3 h = normalize(v + l);   
    float3 diffuse = max(0, dot(n, l)) * albedo;
    float3 specular = pow(max(0, dot(n, h)), shininess) * 0.4;
    return diffuse + specular;
}


// Reflects the given ray from the given hit point
void reflectRay(inout Ray ray, RayHit hit)
{
    float3 n = normalize(hit.normal);
    float3 v = normalize(-ray.direction);
    float3 reflectionDirection = 2*dot(v, hit.normal)*hit.normal - v;
    ray.origin = hit.position + EPS*hit.normal; // move ray by epsilon to avoid acne
    ray.direction = normalize(reflectionDirection);
    ray.energy = ray.energy*hit.material.specular;
}

// Refracts the given ray from the given hit point
void refractRay(inout Ray ray, RayHit hit)
{
    float3 i = normalize(ray.direction);
    float3 n = normalize(hit.normal);
    float eta;
    float n_dot_i = dot(n,i);
    if (n_dot_i<=0) // ray enters the material, so air / eta2
    {
        ray.origin = hit.position - EPS*n; // move ray origin a bit inside the object to avoid acne
        eta = (1/hit.material.refractiveIndex); 
    }
    else // ray exits the material, so eta2 / air and reversed normal
    {
        ray.origin = hit.position + EPS*n; // move ray origin a bit outside the object to avoid acne
        eta = hit.material.refractiveIndex;
        n = -n;
    }
    float c1 = abs(dot(n,i));
    float sinTheta1Squared = 1-pow(c1,2);
    float etaSquared = pow(eta,2);
    float c2Inside = 1-etaSquared*sinTheta1Squared;
    float c2 = sqrt(c2Inside);
    float3 t = eta * i +  (eta * c1 - c2)*n;
    
    ray.direction = normalize(t);
    
}

// Samples the _SkyboxTexture at a given direction vector
float3 sampleSkybox(float3 direction)
{
    float theta = acos(direction.y) / -PI;
    float phi = atan2(direction.x, -direction.z) / -PI * 0.5f;
    return _SkyboxTexture.SampleLevel(sampler_SkyboxTexture, float2(phi, theta), 0).xyz;
}