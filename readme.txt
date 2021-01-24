tamar.yov 318165040
davidnir1 203487293

www.stackoverflow.com
www.google.com
www.unity.com

We implemented intersectPlaneCheckered using the following observation: for every point on the plane, we can decide its color using only the fractional part of each component. If both X and Y have a fractional part larger than 0.5, or both smaller than 0.5, it is enough to determine it will be assigned the material m1, and otherwise m2.

We implemented intersectCylinderY using a similar process to the one we saw in class. 
First, we check for an intersection with the caps using the intersectCircle function.
After we computed the intersection (and updated bestHit) for both caps, we continue to the cylinder walls:
If a ray intersected the cylinder, then the hit point is both on the ray equation (o+dt) and on the cylinder equation which was given in the assignment pdf. We substituted x and z in the cylinder equation with the first and third component of the ray ( ox + dx * t and oz + dz * t ) respectively. Then solved for t. We get a quadratic equation and can find the hitpoint if the discriminant is positive (otherwise no intersection). We get two solutions and choose the smaller one (achieved by the negative root, which is closer to the ray's origin and therefore the first one that the way hits). We now have t, the distance between the hit point and the ray origin. We can use the ray equation to find the hit coordinates, and then make sure the hit is relevant for the finite cylinder too (the distance of the y coordinate of the hit point and the y coordinate of the cylinder center, is less than half the cylinder height).
