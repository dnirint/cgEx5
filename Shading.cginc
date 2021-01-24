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
    // reflection direction: r=2(vn)n-v
    float3 v = normalize(_WorldSpaceCameraPos.xyz - hit.position);
    float3 n = normalize(hit.normal);
    float3 reflectionDirection = normalize(2 * (dot(v,n)) * n - v);
    ray.origin = hit.position;
    ray.direction = reflectionDirection;
    ray.energy = ray.energy*hit.material.specular;
}

// Refracts the given ray from the given hit point
void refractRay(inout Ray ray, RayHit hit)
{
    float3 n = normalize(hit.normal);
    float mu = hit.material.refractiveIndex;
    float n_dot_i = dot(n,ray.direction);
    if (n_dot_i<=0)
    {
        float mu = (1/mu);
    }
    else
    {
        n = -hit.normal;
    }
    
    float3 i = ray.direction;
    float c1 = abs(dot(n,i));
    float first_pow = pow(mu,2);
    float second_pow = 1-pow(c1,2);
    float c2 = sqrt(1-(first_pow*second_pow));
    float3 t = mu * i + (mu * c1 - c2) * n;
    ray.origin = hit.position;
    ray.direction = normalize(t);
    
}

// Samples the _SkyboxTexture at a given direction vector
float3 sampleSkybox(float3 direction)
{
    float theta = acos(direction.y) / -PI;
    float phi = atan2(direction.x, -direction.z) / -PI * 0.5f;
    return _SkyboxTexture.SampleLevel(sampler_SkyboxTexture, float2(phi, theta), 0).xyz;
}