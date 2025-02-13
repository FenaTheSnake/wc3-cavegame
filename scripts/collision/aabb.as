namespace Collision {
    class AABB {
        double minX;
        double minY;
        double minZ;
        double maxX;
        double maxY;
        double maxZ;

        AABB() {}
        // AABB(Vector3 min, Vector3 max) {
        //     this.min = min;
        //     this.max = max;

        //     this.pos = this.min + this.max * 0.5;
        //     this.size = this.max - this.min;
        // }
        AABB(double x1, double y1, double z1, double x2, double y2, double z2)
        {
            this.minX = (x1 < x2) ? x1 : x2;
            this.minY = (y1 < y2) ? y1 : y2;
            this.minZ = (z1 < z2) ? z1 : z2;
            this.maxX = (x1 > x2) ? x1 : x2;
            this.maxY = (y1 > y2) ? y1 : y2;
            this.maxZ = (z1 > z2) ? z1 : z2;
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

        AABB expand(double x, double y, double z)
        {
            double d0 = this.minX;
            double d1 = this.minY;
            double d2 = this.minZ;
            double d3 = this.maxX;
            double d4 = this.maxY;
            double d5 = this.maxZ;

            if (x < 0.0)
            {
                d0 += x;
            }
            else if (x > 0.0)
            {
                d3 += x;
            }

            if (y < 0.0)
            {
                d1 += y;
            }
            else if (y > 0.0)
            {
                d4 += y;
            }

            if (z < 0.0)
            {
                d2 += z;
            }
            else if (z > 0.0)
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

        double calculateXOffset(AABB other, double offsetX)
        {
            if (other.maxY > this.minY && other.minY < this.maxY && other.maxZ > this.minZ+EPSILON && other.minZ < this.maxZ-EPSILON)
            {
                if (offsetX > EPSILON && (DoubleIsEqual(other.maxX, this.minX) || other.maxX < this.minX))
                //if (offsetX > EPSILON && other.maxX <= this.minX)
                {
                    double d1 = this.minX - other.maxX;

                    if (d1 < offsetX)
                    {
                        offsetX = d1;
                    }
                }
                else if (offsetX < EPSILON && (DoubleIsEqual(other.minX, this.maxX) || other.minX > this.maxX))
                //else if (offsetX < EPSILON && other.minX >= this.maxX)
                {
                    double d0 = this.maxX - other.minX;

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
        double calculateYOffset(AABB other, double offsetY)
        {
            if (other.maxX > this.minX && other.minX < this.maxX && other.maxZ > this.minZ+EPSILON && other.minZ < this.maxZ-EPSILON)
            {
                if (offsetY > EPSILON && (DoubleIsEqual(other.maxY, this.minY) || other.maxY < this.minY))
                //if (offsetY > EPSILON && other.maxY <= this.minY)
                {
                    double d1 = this.minY - other.maxY;

                    if (d1 < offsetY)
                    {
                        offsetY = d1;
                    }
                }
                else if (offsetY < EPSILON && (DoubleIsEqual(other.minY, this.maxY) || other.minY > this.maxY))
                //else if (offsetY < EPSILON && other.minY >= this.maxY)
                {
                    
                    double d0 = this.maxY - other.minY;

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
        double calculateZOffset(AABB other, double offsetZ)
        {
            if (other.maxX > this.minX && other.minX < this.maxX && other.maxY > this.minY && other.minY < this.maxY)
            {
                if (offsetZ > 0.0 && (DoubleIsEqual(other.maxZ, this.minZ) || other.maxZ < this.minZ))
                {
                    double d1 = this.minZ - other.maxZ;

                    if (d1 < offsetZ)
                    {
                        offsetZ = d1;
                    }
                }
                else if (offsetZ < 0.0 && (DoubleIsEqual(other.minZ, this.maxZ) || other.minZ > this.maxZ))
                {
                    double d0 = this.maxZ - other.minZ;

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