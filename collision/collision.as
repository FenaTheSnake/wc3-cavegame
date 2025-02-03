#include "aabb.as"

namespace Collision {

    class BlockRaycastInfo {
        World::BlockID block;
        World::BlockPos position;
        Vector3 face;

        BlockRaycastInfo() {}
        BlockRaycastInfo(World::BlockID &in b, World::BlockPos &in p, Vector3 &in f) {
            block = b;
            position = p;
            face = f;
        }
    }

    // raycasts to the world, returns true if hit, and outputs info about collision.
    // checks only for blocks, returns position of the block that was hit (not the hit itself)
    bool RaycastBlock(World::WorldInstance@ world, Vector3 origin, Vector3 direction, float distance, BlockRaycastInfo &out info) {
        float dx = direction.x;
        float dy = direction.y;
        float dz = direction.z;
        if(dx == 0 && dy == 0 && dz == 0) return false;

        float x = MathRealFloor(origin.x / BLOCK_SIZE);
        float y = MathRealFloor(origin.y / BLOCK_SIZE);
        float z = MathRealFloor(origin.z / BLOCK_SIZE);


        float stepX = dx > 0 ? 1 : dx < 0 ? -1 : 0;
        float stepY = dy > 0 ? 1 : dy < 0 ? -1 : 0;
        float stepZ = dz > 0 ? 1 : dz < 0 ? -1 : 0;

        float tMaxX = intbound(origin.x / BLOCK_SIZE, dx);
        float tMaxY = intbound(origin.y / BLOCK_SIZE, dy);
        float tMaxZ = intbound(origin.z / BLOCK_SIZE, dz);

        float tDeltaX = stepX/dx;
        float tDeltaY = stepY/dy;
        float tDeltaZ = stepZ/dz;

        Vector3 face = Vector3();

        int maxIter = 100;
        while(maxIter-- > 0) {
            World::BlockPos bpos = world.GetBlockByAbsoluteBlockPos(World::BlockPos(x, y, z));
            if(bpos.chunk !is null) {
                World::BlockID b = bpos.chunk.blocks[bpos.x][bpos.y][bpos.z];
                if(b != World::BlockID::AIR) {
                    //BlockRaycastInfo test = BlockRaycastInfo(b, Vector3I(), face);
                    info = BlockRaycastInfo(b, bpos, face);
                    return true;
                }
            }

            if(tMaxX < tMaxY) {
                if(tMaxX < tMaxZ) {
                    if(tMaxX > distance) break;
                    x += stepX;
                    tMaxX += tDeltaX;

                    face.x = -stepX; face.y = 0; face.z = 0;
                } else {
                    if(tMaxZ > distance) break;
                    z += stepZ;
                    tMaxZ += tDeltaZ;
                    face.x = 0; face.y = 0; face.z = -stepZ;
                }
            } else {
                if(tMaxY < tMaxZ) {
                    if(tMaxY > distance) break;
                    y += stepY;
                    tMaxY += tDeltaY;
                    face.x = 0; face.y = -stepY; face.z = 0;
                } else {
                    if(tMaxZ > distance) break;
                    z += stepZ;
                    tMaxZ += tDeltaZ;
                    face.x = 0; face.y = 0; face.z = -stepZ;
                }
            }
        }
        return false;
    }

    float intbound(float s, float ds) {
        if(ds < 0) {
            return intbound(-s, -ds);
        } else {
            s = mod(s, 1);
            return (1-s)/ds;
        }
    }
    float mod(float value, float modulus) {
        return (value % modulus + modulus) % modulus;
    }

    // class Contact {
    //     bool isIntersecting;
    //     Vector3 nEnter;
    //     float penetration;

    //     Contact() {}
    // }

    // bool TestStaticAABBAABB(AABB a, AABB b, Contact &out contact)
    // {
    //     // [Minimum Translation Vector]
    //     float mtvDistance = 999999.0f;             // Set current minimum distance (max float value so next value is always less)
    //     Vector3 mtvAxis = Vector3();                // Axis along which to travel with the minimum distance

    //     // [Axes of potential separation]
    //     // • Each shape must be projected on these axes to test for intersection:
    //     //          
    //     // (1, 0, 0)                    A0 (= B0) [X Axis]
    //     // (0, 1, 0)                    A1 (= B1) [Y Axis]
    //     // (0, 0, 1)                    A1 (= B2) [Z Axis]

    //     // [X Axis]
    //     if (!TestAxisStatic(Vector3(1, 0, 0), a.min.x, a.max.x, b.min.x, b.max.x, mtvAxis, mtvDistance))
    //     {
    //         return false;
    //     }

    //     // [Y Axis]
    //     if (!TestAxisStatic(Vector3(0, 1, 0), a.min.y, a.max.y, b.min.y, b.max.y, mtvAxis, mtvDistance))
    //     {
    //         return false;
    //     }

    //     // [Z Axis]
    //     if (!TestAxisStatic(Vector3(0, 0, 1), a.min.z, a.max.z, b.min.z, b.max.z, mtvAxis, mtvDistance))
    //     {
    //         return false;
    //     }

    //     contact.isIntersecting = true;

    //     // Calculate Minimum Translation Vector (MTV) [normal * penetration]
    //     contact.nEnter = mtvAxis.Normalized();

    //     // Multiply the penetration depth by itself plus a small increment
    //     // When the penetration is resolved using the MTV, it will no longer intersect
    //     contact.penetration = SquareRoot(mtvDistance) * 1.001f;

    //     return true;
    // }

    // bool TestAxisStatic(Vector3 axis, float minA, float maxA, float minB, float maxB, Vector3 &out mtvAxis, float &out mtvDistance)
    // {
    //     // [Separating Axis Theorem]
    //     // • Two convex shapes only overlap if they overlap on all axes of separation
    //     // • In order to create accurate responses we need to find the collision vector (Minimum Translation Vector)   
    //     // • Find if the two boxes intersect along a single axis 
    //     // • Compute the intersection interval for that axis
    //     // • Keep the smallest intersection/penetration value
    //     float axisLengthSquared = Vector3DotProduct(axis, axis);

    //     // If the axis is degenerate then ignore
    //     if (axisLengthSquared < 1.0e-8f)
    //     {
    //         return true;
    //     }

    //     // Calculate the two possible overlap ranges
    //     // Either we overlap on the left or the right sides
    //     float d0 = (maxB - minA);   // 'Left' side
    //     float d1 = (maxA - minB);   // 'Right' side

    //     // Intervals do not overlap, so no intersection
    //     if (d0 <= 0.0f || d1 <= 0.0f)
    //     {
    //         return false;
    //     }

    //     // Find out if we overlap on the 'right' or 'left' of the object.
    //     float overlap = (d0 < d1) ? d0 : -d1;

    //     // The mtd vector for that axis
    //     Vector3 sep = axis * (overlap / axisLengthSquared);

    //     // The mtd vector length squared
    //     float sepLengthSquared = Vector3DotProduct(sep, sep);

    //     // If that vector is smaller than our computed Minimum Translation Distance use that vector as our current MTV distance
    //     if (sepLengthSquared < mtvDistance)
    //     {
    //         mtvDistance = sepLengthSquared;
    //         mtvAxis = sep;
    //     }

    //     return true;
    // }

    // bool CircleIntersectRect(Vector2 cpos, float cr, Vector2 rect_pos, Vector2 rect_size) {
    //     Vector2 circleDist = Vector2(MathRealAbs(cpos.x - rect_pos.x), MathRealAbs(cpos.y - rect_pos.y));

    //     if (circleDist.x > (rect_size.x/2 + cr)) { return false; }
    //     if (circleDist.y > (rect_size.y/2 + cr)) { return false; }

    //     if (circleDist.x <= (rect_size.x/2)) { return true; } 
    //     if (circleDist.y <= (rect_size.y/2)) { return true; }

    //     cornerDistance_sq = Pow((circleDist.x - rect_size.x/2),2) +
    //                         Pow((circleDist.y - rect_size.y/2),2);

    //     return (cornerDistance_sq <= Pow(cr,2));
    // }

    // // returns all blocks that cylinder intersects with
    // array<Block@> CylinderIntersectsWorld(Vector3 cpos, float ch, float cr, World::WorldInstance@ world) {
    //     AABB caabb = AABB(cpos, ch, cr);
    //     array<Block@> allBlocks;
    //     array<Chunk@> chunks = world.GetAABBChunks(caabb);

    //     for(uint chunk_iter = 0; chunk_iter < chunks.length(); chunk_iter++){
    //         array<Vector3>@ blocks = @chunks[chunk_iter].GetAABBBlocks(caabb);
    //         for(uint block_iter = 0; block_iter < blocks.length(); block_iter++) {
    //             Block@ b = @chunks[chunk_iter].blocks[blocks.x][blocks.y][blocks.z];
    //             if(b.id != BlockID::AIR) {
    //                 if(CircleIntersectRect( cpos, cr, Vector2(  blocks.x * BLOCK_SIZE + chunks[chunk_iter].position.x + BLOCK_SIZE / 2, 
    //                                                             blocks.y * BLOCK_SIZE + chunks[chunk_iter].position.y + BLOCK_SIZE / 2), 
    //                                         Vector2(BLOCK_SIZE, BLOCK_SIZE))) {
    //                     allBlocks.insertLast()
    //                 }
    //             }
    //         }
    //     }
    // }
}