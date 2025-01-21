namespace Collision {
    class AABB {
        float minX;
        float minY;
        float minZ;
        float maxX;
        float maxY;
        float maxZ;

        AABB() {}
        // AABB(Vector3 min, Vector3 max) {
        //     this.min = min;
        //     this.max = max;

        //     this.pos = this.min + this.max * 0.5;
        //     this.size = this.max - this.min;
        // }
        AABB(float x1, float y1, float z1, float x2, float y2, float z2)
        {
            this.minX = MathRealMin(x1, x2);
            this.minY = MathRealMin(y1, y2);
            this.minZ = MathRealMin(z1, z2);
            this.maxX = MathRealMax(x1, x2);
            this.maxY = MathRealMax(y1, y2);
            this.maxZ = MathRealMax(z1, z2);
        }
        AABB(Vector3 min, Vector3 max) {
            this.minX = min.x;
            this.minY = min.y;
            this.minZ = min.z;
            this.maxX = max.x;
            this.maxY = max.y;
            this.maxZ = max.z;
        }
        // AABB(Vector3 cylinder_center, float cylinder_height, float cylinder_radius) {
        //     this.min = Vector3(cylinder.center.x - cylinder_radius, cylinder.center.y - cylinder_radius, cylinder_center.z - cylinder_height/2);
        //     this.max = Vector3(cylinder.center.x + cylinder_radius, cylinder.center.y + cylinder_radius, cylinder_center.z + cylinder_height/2);

        //     this.pos = this.min + this.max * 0.5;
        //     this.size = this.max - this.min;
        // }

        string opImplConv() const { return "[" + this.minX + "," + this.minY + "," + this.minZ + "] [" + this.maxX + "," + this.maxY + "," + this.maxZ + "]"; }

        AABB expand(float x, float y, float z)
        {
            float d0 = this.minX;
            float d1 = this.minY;
            float d2 = this.minZ;
            float d3 = this.maxX;
            float d4 = this.maxY;
            float d5 = this.maxZ;

            if (x < 0.0f)
            {
                d0 += x;
            }
            else if (x > 0.0f)
            {
                d3 += x;
            }

            if (y < 0.0f)
            {
                d1 += y;
            }
            else if (y > 0.0f)
            {
                d4 += y;
            }

            if (z < 0.0f)
            {
                d2 += z;
            }
            else if (z > 0.0f)
            {
                d5 += z;
            }

            return AABB(d0, d1, d2, d3, d4, d5);
        }

        AABB offset(double x, double y, double z)
        {
            return AABB(this.minX + x, this.minY + y, this.minZ + z, this.maxX + x, this.maxY + y, this.maxZ + z);
        }

        AABB offset(Vector3 v)
        {
            return this.offset(v.x, v.y, v.z);
        }

        float calculateXOffset(AABB other, float offsetX)
        {
            if (other.maxY > this.minY && other.minY < this.maxY && other.maxZ > this.minZ && other.minZ < this.maxZ)
            {
                if (offsetX > EPSILON && other.maxX <= this.minX)
                {
                    float d1 = this.minX - other.maxX;

                    if (d1 < offsetX)
                    {
                        offsetX = d1;
                    }
                }
                else if (offsetX < EPSILON && other.minX >= this.maxX)
                {
                    float d0 = this.maxX - other.minX;

                    if (d0 > offsetX)
                    {
                        offsetX = d0;
                    }
                }

                return offsetX;
            }
            else
            {
                return offsetX;
            }
        }

        /**
        * if instance and the argument bounding boxes overlap in the X and Z dimensions, calculate the offset between them
        * in the Y dimension.  return var2 if the bounding boxes do not overlap or if var2 is closer to 0 then the
        * calculated offset.  Otherwise return the calculated offset.
        */
        double calculateYOffset(AABB other, float offsetY)
        {
            if (other.maxX > this.minX && other.minX < this.maxX && other.maxZ > this.minZ && other.minZ < this.maxZ)
            {
                //__debug("this aabb " + this + " ; other aabb " + other + " ; offsetY" + offsetY);
                if (offsetY > EPSILON && other.maxY <= this.minY)
                {
                    float d1 = this.minY - other.maxY;

                    if (d1 < offsetY)
                    {
                        offsetY = d1;
                    }
                }
                else if (offsetY < EPSILON && other.minY >= this.maxY)
                {
                    
                    float d0 = this.maxY - other.minY;

                    if (d0 > offsetY)
                    {
                        offsetY = d0;
                    }
                }

                return offsetY;
            }
            else
            {
                return offsetY;
            }
        }

        /**
        * if instance and the argument bounding boxes overlap in the Y and X dimensions, calculate the offset between them
        * in the Z dimension.  return var2 if the bounding boxes do not overlap or if var2 is closer to 0 then the
        * calculated offset.  Otherwise return the calculated offset.
        */
        float calculateZOffset(AABB other, float offsetZ)
        {
            if (other.maxX > this.minX && other.minX < this.maxX && other.maxY > this.minY && other.minY < this.maxY)
            {
                if (offsetZ > EPSILON && other.maxZ <= this.minZ)
                {
                    float d1 = this.minZ - other.maxZ;

                    if (d1 < offsetZ)
                    {
                        offsetZ = d1;
                    }
                }
                else if (offsetZ < EPSILON && other.minZ >= this.maxZ)
                {
                    float d0 = this.maxZ - other.minZ;

                    if (d0 > offsetZ)
                    {
                        offsetZ = d0;
                    }
                }

                return offsetZ;
            }
            else
            {
                return offsetZ;
            }
        }
    }
}